%https://uk.mathworks.com/matlabcentral/answers/351973-how-can-i-run-a-few-separate-functions-in-parallell-and-keep-all-of-the-results-in-the-workspace

function test_parallel_functions_2()
clc
parpool(2);
tic
F1 = parfeval(@f1, 3, 1,2,3);
F2 = parfeval(@f2, 3, 'a', 1.5, 'test');
F3 = parfeval(@f3, 3, 9,8,7);
[R1,R2,R3] = fetchOutputs([ F1, F2, F3 ], 'UniformOutput', false);
disp([R1,R2,R3]);
disp('time:');
disp(toc);
delete(gcp('nocreate'));
end
% sleep for 10 seconds to simulate work
function [A,B,C] = f1(A1,B1,C1)
    pause(10);
    A = A1;
    B = B1;
    C = C1;
end
function [D,E,F] = f2(D1,E1,F1)
    pause(5);
    D = D1;
    E = E1;
    F = F1;
end
function [G,H,I] = f3(G1,H1,I1)
    pause(10);
    G = G1;
    H = H1;
    I = I1;
end