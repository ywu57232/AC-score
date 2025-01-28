function output = nmc(bin,param)
nmc_mean = nmc_single(bin,param,'mean');
nmc_median = nmc_single(bin,param,'median');
if nmc_mean.ps > nmc_median.ps  % choose the centroid type with the highest performance score
    output = nmc_mean;
    output.ctype = 'mean';
else 
    output = nmc_median;
    output.ctype = 'median';
end
end


function model = nmc_single(bin,param,ctype)
idx1 = bin.y_train == 1;
if strcmp(ctype, "mean")
    v = mean(bin.x_train(idx1,:)) - mean(bin.x_train(~idx1,:));
elseif strcmp(ctype, "median")
    v = median(bin.x_train(idx1,:)) - median(bin.x_train(~idx1,:));
end
v = v / norm(v);
Q = bin.x_train * v';

model = oop_cross_testdation(Q,bin,param);  % model training with cross-validaiton
model.v=v;

Q_test = bin.x_test*v';     % project validation set onto NMC eigenvector
y_pred = zeros(length(Q_test),1);
y_pred(Q_test >= model.oop) = 1;
r = compute_cm(bin.y_test,y_pred);  % compute confusion matrix   
for k=1:numel(param.metrics)
    model.pe_test(k) = compute_metric(r,param.metrics(k)); % evaluate performance on each metric
end
end


function model = oop_cross_testdation(Q,bin,param)
N = size(Q,1);
numMetrics = numel(param.metrics);
pe_vali=nan(param.g,param.h,numMetrics);    % training test set performance evaluations
model_cr = struct('ps',cell(param.g,param.h),'oop',cell(param.g,param.h));

for i=1:param.h
    rng(param.seeds(i));
    indices = crossvalind('Kfold',N,param.g);
    for j = 1:param.g
        ind_test = find(indices==j);
        ind_train = setdiff(1:N,ind_test)';
        model_cr(j,i) = find_oop(Q(ind_train),bin.y_train(ind_train)); % find OOP for each cross-validation turn 
        y_pred = zeros(numel(ind_test),1); 
        y_pred((Q(ind_test)>=model_cr(j,i).oop)) = 1; % predict as positive to the right of OOP, negative to the left of OOP
        r = compute_cm(bin.y_train(ind_test),y_pred); % compute confusion matrix 
        for k=1:numMetrics
            pe_vali(j,i,k) = compute_metric(r,param.metrics(k)); % get training test set performance evaluations, considering equally positive and negative class.
        end
        disp(['complete NMC ',num2str(i),',',num2str(j)])
    end
end
model.ps = mean([model_cr.ps],"all"); % average performance score across all cross-validations
model.oop = mean([model_cr.oop],"all"); % average OOP across all cross-validations
model.pe_vali= mean(pe_vali,[1,2]); % average performance evaluations on training test set across all cross-validations
end


function model_cr = find_oop(Q,y)
N = size(Q,1);
ps_metrics = ["Fscore1","Fscore2","ACscore"];
[~,ind] = sort(Q);
y = y(ind);
r = struct('tp',cell(N-1,1),'tn',cell(N-1,1),'fp',cell(N-1,1),'fn',cell(N-1,1));
% set oop candidates on each middle point of two consecutive points starting from 
% the left, and predict to the left of OOP as negative, the others as positive, and get each performance evaluation  

y_pred = ones(N,1);
for i=1:N-1
    y_pred(i)=0;  
    r(i) = compute_cm(y,y_pred);
end

e=nan(N-1,3);
for k=1:3
    for i=1:N-1
        e(i,k) = compute_metric(r(i),ps_metrics(k));
    end
end
e=sum(e,2);
[model_cr.ps,~]= max(e,[],"omitnan"); % compute performance score from performance evaluations
ind_e=find(e==model_cr.ps);
N_ie=numel(ind_e);
if N_ie==1
model_cr.oop = (Q(ind(ind_e),1)+Q(ind(ind_e+1),1))/2;
elseif N_ie>1 && rem(N_ie,2)==1
    model_cr.oop = (Q(ind(median(ind_e)),1)+Q(ind(median(ind_e)+1),1))/2;
elseif N_ie>1 && rem(N_ie,2)==0
    oop1 = (Q(ind(ind_e(N_ie/2)),1)+Q(ind(ind_e(N_ie/2)+1),1))/2;
    oop2 = (Q(ind(ind_e(N_ie/2+1)),1)+Q(ind(ind_e(N_ie/2+1)+1),1))/2;
    model_cr.oop = (oop1+oop2)/2;
end
end

function cm = compute_cm(y,y_pred)
cm.tp = sum(y_pred == 1 & y == 1);
cm.tn = sum(y_pred == 0 & y == 0);
cm.fp = sum(y_pred == 1 & y == 0);
cm.fn = sum(y_pred == 0 & y == 1);
end
