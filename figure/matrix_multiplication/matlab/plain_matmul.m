function C=plain_matmul(A,B)

% Check if the dimensions of matrices allow multiplication
[rows_A, cols_A] = size(A);
[rows_B, cols_B] = size(B);

if cols_A ~= rows_B
    disp('Matrix multiplication is not possible because the number of columns in matrix A is not equal to the number of rows in matrix B.');
else
    % Perform matrix multiplication
    C = zeros(rows_A, cols_B);
    for i = 1:rows_A
        for j = 1:cols_B
            for k = 1:cols_A
                C(i,j) = C(i,j) + A(i,k) * B(k,j);
            end
        end
    end
end
