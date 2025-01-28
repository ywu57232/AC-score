
List_N=2.^(7:13);
for method = ["Strassen", "L1-opt_plain", "plain"]
    rng(0)
    for i=1:length(List_N)
        for rp=1:6
            N = List_N(i);
            R1 = rand(N);
            R2 = rand(N);
            R = zeros(N);
            
            profile on
            if strcmp(method, "plain")
                R = plain_matmul(R1,R2);
            elseif strcmp(method, "L1-opt_plain")                
                R = plain_matmul_8x8_man(R,R1,R2);
            elseif strcmp(method, "Strassen")
                R = strassenEq(R1,R2);                
            end            
            profile off

            p(rp,i) = profile("info");
            s(rp,i) = profile("status");
        end
    end
end
results.(method).p = p;
results.(method).s = s;
save("figure/matrix_multiplication/matlab/results_matmul.mat")
