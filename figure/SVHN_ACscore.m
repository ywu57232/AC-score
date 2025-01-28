dbstop if error

load train_32x32.mat
X=transpose(reshape(X,32*32*3,[]));
x_train=double(X)/255; y_train=y;
load test_32x32.mat
X=transpose(reshape(X,32*32*3,[]));
x_test=double(X)/255; y_test=y;

S=load('cr_seeds.mat');
param.seeds=S.seeds;        % fix the seeds used for generating cross-validation folds.
param.metrics=["AUC","AUPR","Fscore","ACscore","acc","MCC","sens","spec"]; 
param.g = 5;
param.h = 10;

classes = unique(y_train,'stable');
param.numClass = numel(classes);

i=1; j=9;
ind_train = any(y_train==[classes(i),classes(j)],2); % pick out subset for each binary classification task
bin.x_train = x_train(ind_train,:);
bin.y_train = y_train(ind_train,:);        

ind_vali = any(y_test==[classes(i),classes(j)],2);
bin.x_test = x_test(ind_vali,:);
bin.y_test = y_test(ind_vali,:);

% tokenize labels to 0 and 1
[bin.y_train,param] = process_labels(bin.y_train,param);
bin.y_test(bin.y_test == param.ClassPos) = 1;
bin.y_test(~(bin.y_test == param.ClassPos)) = 0;
bin0 = bin;

for mode = ["unbalanced","balanced","reverse_unbalanced"]
    bin=proportionate_samples(bin0);
    if any(strcmp(mode, {'balanced','reverse unbalanced'}))
        bin=class_balance(bin);
    end
    if strcmp(mode, 'reverse_unbalanced')
        bin=class_unbalance(bin);
    end
    
    outputs.(mode).nmc = nmc(bin,param);
    outputs.(mode).lda = lda(bin,param); % LDA as the approach to be compared with NMC
    data.(mode) = bin;

    save figure/data/outputs.mat outputs data
end


function bin=proportionate_samples(bin)
ind1=find(bin.y_train==1);
ind2=find(bin.y_train==0);

N1_train=13500;
N2_train=4500;
bin.y_train=bin.y_train(union(ind1(1:N1_train),ind2(1:N2_train)));
bin.x_train=bin.x_train(union(ind1(1:N1_train),ind2(1:N2_train)),:);

ind1=find(bin.y_test==1);
ind2=find(bin.y_test==0);

N1_vali=4500;
N2_vali=1500;
bin.y_test=bin.y_test(union(ind1(1:N1_vali),ind2(1:N2_vali)));
bin.x_test=bin.x_test(union(ind1(1:N1_vali),ind2(1:N2_vali)),:);
end


function bin=class_balance(bin)
n1=sum(bin.y_test==1);
n2=sum(bin.y_test==0);
ind1=find(bin.y_test==1);
ind2=find(bin.y_test==0);
if n1>n2    
    bin.y_test=bin.y_test(union(ind1(1:n2),ind2));
    bin.x_test=bin.x_test(union(ind1(1:n2),ind2),:);
else
    bin.y_test=bin.y_test(union(ind2(1:n2),ind1));
    bin.x_test=bin.x_test(union(ind2(1:n2),ind1),:);
end

n1=sum(bin.y_train==1);
n2=sum(bin.y_train==0);
ind1=find(bin.y_train==1);
ind2=find(bin.y_train==0);
if n1>n2    
    bin.y_train=bin.y_train(union(ind1(1:n2),ind2));
    bin.x_train=bin.x_train(union(ind1(1:n2),ind2),:);
else
    bin.y_train=bin.y_train(union(ind2(1:n1),ind1));
    bin.x_train=bin.x_train(union(ind2(1:n1),ind1),:);
end
end


function bin=class_unbalance(bin)
ind1=find(bin.y_train==1);
ind2=find(bin.y_train==0);

n=round(4500^2/13500);
bin.y_train=bin.y_train(union(ind1(1:n),ind2));
bin.x_train=bin.x_train(union(ind1(1:n),ind2),:);

n=round(1500^2/4500);
ind1=find(bin.y_test==1);
ind2=find(bin.y_test==0);

bin.y_test=bin.y_test(union(ind1(1:n),ind2));
bin.x_test=bin.x_test(union(ind1(1:n),ind2),:);
end


function [Ts,param]= process_labels(T,param) % take the first sample as positive class, and the other as negative class.
G=unique(T,'stable');
Ts=ones(size(T),'logical');
param.ClassPos=G(1);
param.ClassNeg=G(2);
Ts(T==G(1),1) = 1;
Ts(T==G(2),1) = 0;
end
