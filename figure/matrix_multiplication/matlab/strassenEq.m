function C = strassenEq(A, B)
    n = length(A);
    m = 2^nextpow2(n);
    APrep = zeros(m);
    BPrep = zeros(m);
    APrep(1:n, 1:n) = A;
    BPrep(1:n, 1:n) = B;
    CPrep = strassenR(APrep, BPrep);
    C = CPrep(1:n, 1:n);
end


function C = ikj_matrix_product(A, B)
    n = length(A);
    C = zeros(n);
    for i = 1:n
        for k = 1:n
            for j = 1:n
                C(i,j) = C(i,j) + A(i,k) * B(k,j);
            end
        end
    end
end

function C = add(A, B)
    n = length(A);
    C = zeros(n);
    for i = 1:n
        for j = 1:n
            C(i,j) = A(i,j) + B(i,j);
        end
    end
end

function C = subtract(A, B)
    n = length(A);
    C = zeros(n);
    for i = 1:n
        for j = 1:n
            C(i,j) = A(i,j) - B(i,j);
        end
    end
end

function C = strassenR(A, B)
    LEAF_SIZE = 8; % Define LEAF_SIZE value as needed
    n = length(A);

    if n <= LEAF_SIZE
        C = ikj_matrix_product(A, B);
    else
        new_size = floor(n / 2);

        a11 = A(1:new_size, 1:new_size);
        a12 = A(1:new_size, new_size+1:end);
        a21 = A(new_size+1:end, 1:new_size);
        a22 = A(new_size+1:end, new_size+1:end);

        b11 = B(1:new_size, 1:new_size);
        b12 = B(1:new_size, new_size+1:end);
        b21 = B(new_size+1:end, 1:new_size);
        b22 = B(new_size+1:end, new_size+1:end);

        aResult = add(a11, a22);
        bResult = add(b11, b22);
        p1 = strassenR(aResult, bResult);

        aResult = add(a21, a22);
        p2 = strassenR(aResult, b11);

        bResult = subtract(b12, b22);
        p3 = strassenR(a11, bResult);

        bResult = subtract(b21, b11);
        p4 = strassenR(a22, bResult);

        aResult = add(a11, a12);
        p5 = strassenR(aResult, b22);

        aResult = subtract(a21, a11);
        bResult = add(b11, b12);
        p6 = strassenR(aResult, bResult);

        aResult = subtract(a12, a22);
        bResult = add(b21, b22);
        p7 = strassenR(aResult, bResult);

        c12 = add(p3, p5);
        c21 = add(p2, p4);

        aResult = add(p1, p4);
        bResult = add(aResult, p7);
        c11 = subtract(bResult, p5);

        aResult = add(p1, p3);
        bResult = add(aResult, p6);
        c22 = subtract(bResult, p2);

        C = zeros(n);
        C(1:new_size, 1:new_size) = c11;
        C(1:new_size, new_size+1:end) = c12;
        C(new_size+1:end, 1:new_size) = c21;
        C(new_size+1:end, new_size+1:end) = c22;
    end
end


