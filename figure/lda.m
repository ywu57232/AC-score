function model = lda(bin,param)
[N,M]= size(bin.x_train);
N_test = size(bin.x_test,1);
numMetrics = numel(param.metrics);

pe_vali=nan(param.g,param.h,numMetrics);
v_mat=nan(M+1,param.g*param.h);
for i=1:param.h
    rng(param.seeds(i));
    indices = crossvalind('Kfold',N,param.g);
    for j = 1:param.g
        ind_test = find(indices==j);
        ind_train = setdiff(1:N,ind_test)';
        Mdl = fitcdiscr(bin.x_train(ind_train,:),bin.y_train(ind_train),'discrimType','pseudoLinear','OptimizeHyperparameters','none');
        v = [Mdl.Coeffs(2,1).Linear;Mdl.Coeffs(2,1).Const];
        v_mat(:,param.g*(i-1)+j)= v;
        y_pred = predict(Mdl,bin.x_train(ind_test,:));
        r = compute_cm(bin.y_train(ind_test),y_pred);
        for k=1:numMetrics
            pe_vali(j,i,k) = compute_metric(r,param.metrics(k));
        end
        disp(['complete LDA ',num2str(i),',',num2str(j)])
    end
end
model.pe_vali= mean(pe_vali,[1,2],'omitnan');
model.v = mean(v_mat,2);
model.v = model.v / norm(model.v);

Q = [bin.x_test,ones(N_test,1)] * model.v;
y_pred = zeros(N_test,1);
y_pred(Q>=0)=1;
r = compute_cm(bin.y_test,y_pred);    
for k=1:numel(param.metrics)
    model.pe_test(k) = compute_metric(r,param.metrics(k));
end
end


function cm = compute_cm(y,y_pred)
cm.tp = sum(y_pred == 1 & y == 1);
cm.tn = sum(y_pred == 0 & y == 0);
cm.fp = sum(y_pred == 1 & y == 0);
cm.fn = sum(y_pred == 0 & y == 1);
end