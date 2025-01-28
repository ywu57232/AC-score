% An example of ETC usage.

% Provide the algorithm to test for empirical scalability.
alg = @plain_matmul;
% Provide the algorithm to generate data for the tested algorithm with a argument of a single size.
algDataGen_ = @algDataGen;

baseSize = 2^7; % The smallest dimensional size.
numTest = 3; % Number of different input sizes to test runtimes and ETCs.
repeat = 5; % Number of repetition for each input size.

etc = ETC(alg, algDataGen_, baseSize, numTest, repeat);


function data = algDataGen(Size)
% matmul
data{1} = rand(Size);
data{2} = rand(Size);
end