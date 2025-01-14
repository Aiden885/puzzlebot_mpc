function varargout = mobile_robot_platform(varargin)
% MOBILE_ROBOT_PLATFORM MATLAB code for mobile_robot_platform.fig
%      MOBILE_ROBOT_PLATFORM, by itself, creates a new MOBILE_ROBOT_PLATFORM or raises the existing
%      singleton*.
%
%      H = MOBILE_ROBOT_PLATFORM returns the handle to a new MOBILE_ROBOT_PLATFORM or the handle to
%      the existing singleton*.
%
%      MOBILE_ROBOT_PLATFORM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOBILE_ROBOT_PLATFORM.M with the given input arguments.
%
%      MOBILE_ROBOT_PLATFORM('Property','Value',...) creates a new MOBILE_ROBOT_PLATFORM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mobile_robot_platform_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mobile_robot_platform_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mobile_robot_platform

% Last Modified by GUIDE v2.5 20-Sep-2020 14:30:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mobile_robot_platform_OpeningFcn, ...
                   'gui_OutputFcn',  @mobile_robot_platform_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before mobile_robot_platform is made visible.
function mobile_robot_platform_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mobile_robot_platform (see VARARGIN)

%% Version check
if verLessThan('matlab','8.4.0')
    error('Mobot Robot Platform requires at least MATLAB version 8.4 (R2014b) or newer.')
end

%% Startup
restoredefaultpath
addpath(genpath(pwd))

%% Display parameters
font_size = 10;

%% Create the layout
vbox = uix.VBoxFlex('Parent', handles.uipanel1, ...
    'Units', 'Normalized', 'Position', [0 0 1 1], ...
    'Spacing', 5 );

%% Top section (axes)
panel = uix.Panel( 'Parent', vbox);
handles.axes1 = axes( 'Parent', panel, 'ActivePositionProperty', 'outerposition');
% Create empty world (default)
axes(handles.axes1)
handles.world = WorldClass();
handles.h_w = handles.world.plot();
xlabel('x (meters)')
ylabel('y (meters)')

%% Bottom section (tab panel)
tabpanel = uix.TabPanel( 'Parent', vbox, 'Padding', 0);
vbox.Heights = [-5 -2];     % ratio of 5 to 2 height

% Robot Tab
htab2 = uix.Panel( 'Parent', tabpanel, 'Padding', 5);
% Create layout for robot tab
hbox = uix.HBoxFlex('Parent', htab2, 'Units', 'Normalized',...
    'Position', [0 0 1 1], 'Spacing', 5 );

% Create table on the left
handles.robot_table = uitable('Parent', hbox);
% Create axes on the right
right_panel = uix.Panel( 'Parent', hbox);
handles.axes2 = axes( 'Parent', right_panel, 'ActivePositionProperty', 'position');
hbox.Widths = [-8 -1];     % ratio of 8 to 1 height
% Add information to the table
cols_names = {'File name';...
              'Control file';...
              'IP address';...
              '2D Pose|(x, y, theta)';...
              'Communication|status'};
set(handles.robot_table,'ColumnName',cols_names)
set(handles.robot_table,'FontSize', font_size)
set(handles.robot_table, 'ColumnEditable', logical([1 1 1 1 0]))
set(htab2, 'SizeChangedFcn', str2func('@(hObject,eventdata)mobile_robot_platform(''resize_window_clickedCallback'',hObject,eventdata,guidata(hObject))'))
set(handles.robot_table, 'CellEditCallback', str2func('@(hObject,eventdata)mobile_robot_platform(''robot_table_EdittedCallback'',hObject,eventdata,guidata(hObject))'))

% Add robot (default)
% Supports only one robot but it can easily be extended to multiple robots
% TODO: Support multiple robots when communication issue is sorted
robot_data = {'puzzle_bot_0002.json', '', '192.168.1.1',...
    '[0, 0, 0]', 'offline'};
set(handles.robot_table, 'Data', robot_data);

% These calls below are for the first time when the GUI launches
handles = resize_robot_table_columns(handles);
handles = update_robot_info_from_robot_table(handles, 0, 0);

% World Tab
%htab1 = uix.Panel( 'Parent', tabpanel, 'Padding', 5);
htab1 = uipanel('Parent', tabpanel, 'Units', 'pixels');
% Assume that panel's height is at least 100 pixels
% TODO: Fix this later to change when resizing so positions of components
% below also change.
% Divide the panel horizontally to 3 rows. Height of each row is 20 pixels
% (that should fit one line of text). Vertical space between rows is 10 pixels.
% Width of each cell is varying depends on column in use (see below)

% Add static text (world limits)
uicontrol( 'Style', 'text', 'Parent', htab1, ...
    'String', {'World limits:'}, 'Units', 'pixels',...
    'FontSize', font_size,...,
    'HorizontalAlignment', 'left', 'Position', [10 30 100 20] );
% Add Edit text (world limits)
handles.session_uitextedit1 = uicontrol( 'Style', 'edit', 'Parent', htab1, ...
    'String', ['[' num2str([get(handles.axes1, 'XLim') get(handles.axes1, 'YLim')]) ']'],...
    'Units', 'pixels',...
    'FontSize', font_size, 'Background', 'w',...
    'HorizontalAlignment', 'center', 'Position', [110 30 100 20],...
    'Callback', str2func('@(hObject,eventdata)mobile_robot_platform(''session_uitextedit1_EdittedCallback'',hObject,eventdata,guidata(hObject))'));

% Add static text (frame rate)
handles.plot_every_second = 0.1;    % (default)
uicontrol( 'Style', 'text', 'Parent', htab1, ...
    'String', 'Frame rate (Hz):', 'Units', 'pixels',...
    'FontSize', font_size,...,
    'HorizontalAlignment', 'left', 'Position', [10 10 100 20] );
% Add Edit text (world limits)
handles.session_uitextedit2 = uicontrol( 'Style', 'edit', 'Parent', htab1, ...
    'String', num2str(1 / handles.plot_every_second),...
    'Units', 'pixels',...
    'FontSize', font_size, 'Background', 'w',...
    'HorizontalAlignment', 'center', 'Position', [110 10 100 20],...
    'Callback', str2func('@(hObject,eventdata)mobile_robot_platform(''session_uitextedit2_EdittedCallback'',hObject,eventdata,guidata(hObject))'));

%{
% Add checkbox (show robot estimate path)
handles.session_uicheckbox1 = uicontrol( 'Style', 'check', 'Parent', htab1, ...
    'String', 'Show robot path (estimate)',...
    'Units', 'pixels', 'FontSize', font_size, 'HorizontalAlignment', 'left',...
    'Position', [250 10 200 20]);
%}
% Add checkbox (show robot true path)
handles.session_uicheckbox2 = uicontrol( 'Style', 'check', 'Parent', htab1, ...
    'String', 'Show robot path (true)',...
    'Units', 'pixels', 'FontSize', font_size, 'HorizontalAlignment', 'left',...
    'Position', [250 10 200 20]);

% Add checkbox (show robot range measurements)
handles.session_uicheckbox3 = uicontrol( 'Style', 'check', 'Parent', htab1, ...
    'String', 'Show range measurements',...
    'Units', 'pixels','FontSize', font_size, 'HorizontalAlignment', 'left',...
    'Position', [250 30 200 20]);

% Add checkbox (connect to physical robot)
handles.session_uicheckbox4 = uicontrol( 'Style', 'check', 'Parent', htab1, ...
    'String', 'Connect to physical robot',...
    'Units', 'pixels','FontSize', font_size, 'HorizontalAlignment', 'left',...
    'Position', [500 10 200 20]);

% Update the tab titles
tabpanel.TabTitles = {'Robot', 'Session'};


% Choose default command line output for mobile_robot_platform
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mobile_robot_platform wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mobile_robot_platform_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% >>>>>> Select world <<<<<<<
supported_file_ext = {'*.mat; *.json'};
% open dialog box
[file, path] = uigetfile(fullfile(pwd, 'world_examples', supported_file_ext), 'Select world');
if ~isequal(file, 0)
    handles.world = WorldClass('fname', fullfile(path, file));
    axes(handles.axes1)
    delete(handles.h_w)
    handles.h_w = handles.world.plot();

    % Update world limits editbox
    set(handles.session_uitextedit1, 'String', ['[' num2str(axis) ']'])
end


% Update handles structure
handles.output = hObject;
guidata(hObject, handles);


% --------------------------------------------------------------------
function uipushtool4_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% >>>>>>> Edit world <<<<<<<
delete(handles.h_w)
handles.h_w = handles.world.edit(handles.axes1);

% Update handles structure
handles.output = hObject;
guidata(hObject, handles);


% --------------------------------------------------------------------
function uipushtool5_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% >>>>> Save world <<<<<<
supported_file_ext = {'*.mat'};
% open dialog box
[file, path] = uiputfile(fullfile(pwd, 'world_examples', supported_file_ext), 'Save world');
if ~isequal(file, 0)
    handles.world.save(fullfile(path, file))
end


% --------------------------------------------------------------------
function resize_window_clickedCallback(hObject, eventdata, handles)
% No need to return output and update handles since we are not adding new
% fields but we do edit existing.
resize_robot_table_columns(handles);


function handles = resize_robot_table_columns(handles)
% Resize table columns to fit window after resizing

pos = get(handles.robot_table, 'Position');
n_cols = length(get(handles.robot_table, 'ColumnName'));
col_width = max(100, (pos(3)) / n_cols);     % min width 100
set(handles.robot_table, 'ColumnWidth', {col_width})


% --------------------------------------------------------------------
function robot_table_EdittedCallback(hObject, eventdata, handles)

row_ind = 0;
col_ind = 0;
if ~isempty(eventdata)
    % Update only specified column 
    row_ind = eventdata.Indices(1);
    col_ind = eventdata.Indices(2);
end

handles = update_robot_info_from_robot_table(handles, row_ind, col_ind);

handles.output = hObject;
guidata(hObject, handles);


function handles = update_robot_info_from_robot_table(handles, row_ind, col_ind)
% Update robot full plot when robot file name changes
% row_ind not used now, but when we have multiple robot then this one is important
% col_ind updates from all columns if set to 0


update_robot_plot_in_world = false;
% Update handles
robot_data = get(handles.robot_table, 'Data');
if col_ind == 0 || col_ind == 1
    % save old pose if possible
    try
        old_pose = handles.robot.transformation;
    catch
        old_pose = [];
    end
    handles.robot = RobotClass('json_fname', robot_data{1});
    if ~isempty(old_pose)
        handles.robot.set_transformation(old_pose)
    end
    % Plot robot in full
    axes(handles.axes2)
    cla
    handles.robot.plot('full', eye(4));
    axis equal
    grid off
    %xlabel('x'), ylabel('y'), zlabel('z')
    set(handles.axes2, 'Xticklabel', []),       set(handles.axes2, 'Xtick', [])
    set(handles.axes2, 'Yticklabel', []),       set(handles.axes2, 'Ytick', [])
    set(handles.axes2, 'Zticklabel', []),       set(handles.axes2, 'Ztick', [])
    update_robot_plot_in_world = true;
end
if col_ind == 0 || col_ind == 2
    handles.control_file = robot_data{2};
end
if col_ind == 0 || col_ind == 3
    handles.robot_ip_address = robot_data{3};
end
if col_ind == 0 || col_ind == 4
    handles.robot.set_transformation(pose2d_to_transformation3d(str2num(robot_data{4})))
    update_robot_plot_in_world = true;
end
% Plot robot in world
if update_robot_plot_in_world
    axes(handles.axes1)
    try
        delete(handles.h_r)
    catch
    end
    if ~ishold,     hold on;    end
    handles.h_r = handles.robot.plot('simple');
    % Delete other dynamic plot handles
    handles = delete_dynamic_plot_handles(handles);
end


% --------------------------------------------------------------------
function uipushtool7_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% >>>>>> Add robot to table <<<<<<<
% At the moment we only support one robot since communication only allows
% this.

% (1) Select robot file
supported_file_ext = {'*.json'};
[file, path] = uigetfile(fullfile(pwd, 'hardware_definitions', supported_file_ext), 'Select robot');
if ~isequal(file, 0)
    handles.robot_table.Data{1} = file;
else
    return
end
% (2) Select control file
supported_file_ext = {'*.m; *.p'};
[file, path] = uigetfile(fullfile(pwd, 'my_examples', supported_file_ext), 'Select control file');
if ~isequal(file, 0)
    handles.robot_table.Data{2} = file;
end
% (3) Update handles structure
handles = update_robot_info_from_robot_table(handles, 0, 0);
handles.output = hObject;
guidata(hObject, handles);


% --------------------------------------------------------------------
function session_uitextedit1_EdittedCallback(hObject, eventdata, handles)

% Make sure limits are valid
try
    lims = str2num(get(handles.session_uitextedit1, 'String'));
    set(handles.axes1, 'XLim', lims(1:2))
    set(handles.axes1, 'YLim', lims(3:4))
catch
    % Set limits in editbox to current valid limits
    x_lims = get(handles.axes1, 'XLim');
    y_lims = get(handles.axes1, 'YLim');
    set(handles.session_uitextedit1, 'String', ['[' num2str([x_lims y_lims]) ']'])
end
% Update handles structure
handles.output = hObject;
guidata(hObject, handles);


% --------------------------------------------------------------------
function session_uitextedit2_EdittedCallback(hObject, eventdata, handles)

% >>>>>> Plot update frequency <<<<<<
time_period = 1 / str2double(get(handles.session_uitextedit2, 'String'));
if time_period < 0 || is_close(time_period, 0) || ~isfinite(time_period)
    set(handles.session_uitextedit2, 'String', num2str(1 / handles.plot_every_second))
else
    handles.plot_every_second = time_period;
end
% Update handles structure
handles.output = hObject;
guidata(hObject, handles);


% --------------------------------------------------------------------
function uipushtool2_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% >>>>>>>>>> Run Session <<<<<<<<<<<<<
%% Only run if not already running
if get(handles.uipushtool2, 'UserData')
    return
end

%% Get control filename without extension
if exist(handles.control_file, 'file')
    [~, control_filename, ~] = fileparts(handles.control_file);
end

%% Initialize parameters for the loop
plot_old_time = 0;
num_format = '%0.2f';
exteroceptive_inds = [];    % indice of exteroceptive sensors (for plotting measurements)
try
    for ind = handles.robot.sensor_inds
        if strcmp(handles.robot.components_tree.get(ind).subcategory, 'exteroceptive')
            exteroceptive_inds = [exteroceptive_inds ind];
        end
    end
catch
end
true_path = nan(2, 500);        % keep only 500 poses
% Delete all plot handles enabled by check boxes
handles = delete_dynamic_plot_handles(handles);

%% Initialize `my_alg` map (hash table)
my_alg = containers.Map();
my_alg('tic') = tic;            % updates everytime step and can be used in time-related functions
my_alg('is_first_time') = true; % flag changes to false after the first time step.
my_alg('is_done') = false;      % flag to stop simulation
my_alg('dc_motor_signal_mode') = 'omega_setpoint';
my_alg('plots') = {};           % List of commands to plot in the main figure

%% Connect to physical robot if possible
if get(handles.session_uicheckbox4, 'Value')
    % Try to connect to the robot
    handles.robot.connect(handles.robot_ip_address)
end
% Update robot table
if handles.robot.connected
    handles.robot_table.Data{1, 5} = 'online';
else
    handles.robot_table.Data{1, 5} = 'offline';
    set(handles.session_uicheckbox4, 'Value', 0)
end

%% Disable some GUI components
set(handles.uipushtool2, 'UserData', true)
change_gui_components_state(handles, 'off')

%% Run the main loop
%try    
    while true
        %% (1) Get input signals from my_alg
        actuator_signals = {};
        for ind = handles.robot.actuator_inds
            k = handles.robot.components_tree.get(ind).label;
            try
                v = my_alg(k);
            catch
                v = 0;
            end
            actuator_signals = cat(2, actuator_signals, {k, v});
        end
        
        %% (2) Compute change in time for robot update (simulation)
        try
            dt = toc(t_last_robot_update);
        catch
            dt = 0;
        end
        t_last_robot_update = tic;       % reset stopwatch

        %% (3) Move robot and update all sensors
        sensor_readings = handles.robot.update(dt, handles.world, 'kinematics',...
            my_alg('dc_motor_signal_mode'), actuator_signals{:});
        ks = keys(sensor_readings);
        for i = 1:length(ks)
            my_alg(ks{i}) = sensor_readings(ks{i});
        end
        
        %% (4) Terminate session if triggered by my_alg or GUI stop button
        if my_alg('is_done') || ~get(handles.uipushtool2, 'UserData')
            break
        end
        
        %% (5) Apply control algorithm
        my_alg = feval(control_filename, my_alg, handles.robot);
        
        %% (6) Update GUI
        t_now = toc(my_alg('tic'));
        if t_now - plot_old_time > handles.plot_every_second
            plot_old_time = t_now;
            axes(handles.axes1)
            title(['Time ' num2str(t_now, num_format) ' sec.'])
            % Delete all old plot handles (dynamic) except world handle (static)
            delete(handles.h_r)
            handles = delete_dynamic_plot_handles(handles);
            % Robot plot
            handles.h_r = handles.robot.plot('simple');
            % Plot exteroceptive sensor measurements
            if get(handles.session_uicheckbox3, 'Value')
                handles.h_s = [];
                for ind = exteroceptive_inds
                    handles.h_s = [handles.h_s, handles.robot.plot_measurements(ind)];
                end
            end
            
            % Plot simulated robot path
            pose_2d = transformation3d_to_pose2d(handles.robot.transformation);
            true_path = circshift(true_path, -1, 2);
            true_path(:, end) = pose_2d(1:2);
            if get(handles.session_uicheckbox2, 'Value')
                handles.h_true_path = plot(true_path(1, :), true_path(2, :), 'g--', 'LineWidth', 2);
            end
            
            % Plot in my_alg
            my_alg_plots = my_alg('plots');
            for i = 1:length(my_alg_plots)
                try
                    handles.h_my_alg_plots = [handles.h_my_alg_plots;...
                        eval(my_alg_plots{i})'];
                catch
                end
            end
            
            % Update robot pose in robot table
            s1 = sprintf([num_format ', '] , pose_2d');
            handles.robot_table.Data{1, 4} = ['[' s1(1:end-2) ']'];
            % This pause is necessary to display plot
            pause(1e-2)
        end
        
        %% (7) Update `my_alg` map
        if my_alg('is_first_time'),     my_alg('is_first_time') = false;	end
        my_alg('plots') = {};       % reset plots
    end
%catch ME
%    disp(['Error in GUI main loop: ' ME.message])
%end
%% Enable GUI components
set(handles.uipushtool2, 'UserData', false)
change_gui_components_state(handles, 'on')

%% Disconnect Robot
handles.robot.disconnect();

% Update handles structure
handles.output = hObject;
guidata(hObject, handles);


% --------------------------------------------------------------------
function uipushtool3_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% >>>>>>>>>> Stop Session <<<<<<<<<<<<<
set(handles.uipushtool2, 'UserData', false)
change_gui_components_state(handles, 'on')    % Enable some GUI components


function change_gui_components_state(handles, state)
% state can either be 'on' or 'off'

set(handles.uipushtool1, 'Enable', state)   % world select
set(handles.uipushtool4, 'Enable', state)   % world edit
set(handles.uipushtool5, 'Enable', state)   % world save
set(handles.uipushtool7, 'Enable', state)   % robot add
set(handles.robot_table, 'Enable', state)   % robot table
set(handles.session_uicheckbox4, 'Enable', state)   % connect to physical robot
set(handles.session_uitextedit2, 'Enable', state)   % Frame rate


function handles = delete_dynamic_plot_handles(handles)
% Delete plot handles for: exteroceptive measurements, true path,
% and any plot added by the user

try
    delete(handles.h_s)     % exteroceptive measurements
catch
    handles.h_s = [];
end
try
    delete(handles.h_true_path)     % robot true path
catch
    handles.h_true_path = [];
end
try
    delete(handles.h_my_alg_plots)  % plots in my_alg
catch
    handles.h_my_alg_plots = [];
end
