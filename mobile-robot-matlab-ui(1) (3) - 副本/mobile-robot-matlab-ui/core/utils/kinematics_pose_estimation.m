
% -------------------------------------------------------------------------
% KINEMATICS_POSE_ESTIMATION    computes the robot new pose using its
% kinematics model.
% 
% Robot can have any wheel configuration, and it is assmued moving in 2D
% world (ramps are not supported).
%
% Not all wheels contribute to this kinematics model! If the following
% conditions apply then the wheel affects the model:
%   - wheel is driven by a DC-motor. Compounded motor configuration, e.g.
%     DC motor connected to another DC motor in series is not considered.
%     Only the immediate parent controls the wheel angular velocity. Such
%     wheel is called active_wheel.
%   - wheel must have the normal vector to its plane perpendicular to the
%     world z-axis, that is, wheel must have vertical contact with the
%     world xy-plane. This condition might change over time especially when
%     the drive motor is steered by another motor. 
%
% Notes: 
%   - Other motors (DC or servo) can be connected to the drive DC-motor but
%     they must be used for steering only, i.e. they rotate the drive motor
%     around the world z-axis.
%   - The z-position of the wheel is ignored, i.e. it's assumed all valid
%     wheels are in contact with the world xy-plane.
%
% This function uses robot object to ONLY extract wheel initial properties 
% and transfromations with respect to the robot local frame. Other robot
% properties, such as transformation or motor velocities, are not used to
% compute the new pose. This is because it's possible to use this function
% for dead reckoning localization where such class keeps track of its own
% representation of pose. Moreover, when physical/real robot is used
% `robot.transformation` is not necessarily updated, and wheel velocity is
% measured using encoder, if available.
%
% Usage
%   [pose_new, Dp_p, Dp_w, omegas_rhr] = ...
%       KINEMATICS_POSE_ESTIMATION(robot, pose_old, d_t, omegas_map);
%
% Parameters
%   robot    	(1, 1)  RobotClass object.
%   pose_old	(3, k)  Robot old pose in 2D world (x, y, th) with respect
%                       to  world reference frame. k is the number of poses
%                       to update.
%   d_t         (1, 1)  Time step at which wheel angular velocities are
%                       assumed constant.
%   omegas_map	(1, 1)  containers.Map object (hash table) with keys
%                       storing either wheel index or wheel label, and
%                       values storing angular velocities. The rotation 
%                       convension of each wheel is determined from robot
%                       object and defined in the robot JSON-file. This map
%                       does not have to include all active wheels. Missing
%                       wheels are assigned 0 angular velocities.
%
% Returns
%   pose_new    (3, k)      Robot new pose in 2D world (x, y, th) with
%                           resepect to  world reference frame.
%   Dp_p        (3, 3, k)   Jacobian of pose_new wrt pose_old (x, y, th).
%   Dp_w        (3, n, k)   Jacobian of pose_new wrt robot_velocities
%                           (v_x, v_y, w), where n is the number of valid
%                           active wheels.
%   omegas_rhr  (n, 1)      Angular velocities of all valid active wheels
%                           (even those that are not in omegas_map) in rhr
%                           rotation convension. This output is congruent
%                           with Dp_w in terms of entries order (this order
%                           is not present in omegas_map becuase it's a
%                           hash table), and both are needed to compute the
%                           motion additive noise covariance in
%                           localization.
%
% Reference
%   Introduction to Autonomous Mobile Robots (Chapter 3)
%   https://www.dis.uniroma1.it/~oriolo/amr/slides/Localization1_Slides.pdf
%   https://robotacademy.net.au/lesson/derivative-of-a-rotation-matrix/
%
% Implementation
%   Mohamed Mustafa, August 2020
% -------------------------------------------------------------------------

