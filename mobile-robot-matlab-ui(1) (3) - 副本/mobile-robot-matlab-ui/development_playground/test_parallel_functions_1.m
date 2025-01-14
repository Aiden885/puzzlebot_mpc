% https://uk.mathworks.com/matlabcentral/answers/503649-running-functions-in-parallel

function test_parallel_functions_1()
clc;
pause on
tic;
parpool(2);
f1 = parfeval(@Function_I, 1);
f2 = parfeval(@Function_II, 2);
function1=Function_I();
function2=Function_II();
delete(gcp('nocreate'));

function func1 = Function_I()
    
        disp('Starting function 1:');  
        startF1=toc
            a=5;
            b=6;
            func1=a*b;
            pause(0.1);
        disp('End function 1:');    
        EndF1=toc
    

function func2 = Function_II()
    
        disp('Starting function 2:');    
        StartF2=toc
        a=4;
        b=6;
        func2=a*b;
        pause(0.1);
        disp('End function 2:');    
        EndF2=toc
        