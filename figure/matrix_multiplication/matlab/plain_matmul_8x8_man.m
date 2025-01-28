function C = plain_matmul_8x8_man(C,A,B)

% Check if the dimensions of matrices allow multiplication
[rows_A, cols_A] = size(A);
[rows_B, cols_B] = size(B);
% A=transpose(A);

if cols_A ~= rows_B
    disp('Matrix multiplication is not possible because the number of columns in matrix A is not equal to the number of rows in matrix B.');
else
    N=rows_A;
    stride=2^3;
    for jj = 1:stride:N
        for ii = 1:stride:N
            for kk = 1:stride:N
                for j = jj:jj+stride-1
                    for i = ii:ii+stride-1                    
                        for k = kk:kk+stride-1
                            C(i, j) = C(i, j) + A(i, k) * B(k, j);
                        end
                    end
                end
            end
        end
    end
end

end


