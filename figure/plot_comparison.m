dbstop if error

MAG=1;
f1=figure(1);
f1.Units='centimeters';
f1.Position(3:4)=[18,12]*MAG;


load outputs.mat
bin = data.unbalanced;
outputs = outputs.unbalanced;

subplot(2,3,1), hold on

Q_nmc=bin.x_test*outputs.nmc.v';
oop=outputs.nmc.oop-min(Q_nmc);
Q_nmc=Q_nmc-min(Q_nmc);
oop=oop/max(Q_nmc);
Q_nmc=Q_nmc/max(Q_nmc);

Q_lda=bin.x_test*outputs.lda.v(1:end-1);
b=outputs.lda.v(end)+min(Q_lda);
Q_lda=Q_lda-min(Q_lda);
b=b/max(Q_lda);
Q_lda=Q_lda/max(Q_lda);

histogram(Q_nmc,0:0.025:1,'Normalization','probability','FaceColor',[0.9,0.1,0.1],'FaceAlpha',0.8)
histogram(Q_lda,0:0.025:1,'Normalization','probability','FaceColor',[0.6,0.6,0.6],'FaceAlpha',0.8)
plot([oop,oop],[0,0.2],'--','Color',[0.9,0.1,0.1],'LineWidth',1.5)
plot([-b,-b],[0,0.2],'--','Color',[0.6,0.6,0.6],'LineWidth',1.5)
text(oop+0.09,0.13,'OOP-NMC','Rotation',90,'FontSize',5)
text(-b-0.04,0.13,'LDA cut','Rotation',90,'FontSize',5)


xlim([0,1])
ylabel("Probability")
xlabel("Normalized projection coordinates")
t1=title("{\rm Neg\_samples=1500, Pos\_samples=4500}");
t1.Position(2)=t1.Position(2)+0.005;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot(2,3,4), hold on

nm=11;

y_test=bin.y_test;
y_test(y_test == 2) = 0;

pred_nmc=ones(size(Q_nmc));
pred_nmc(Q_nmc<oop)=0;
r_nmc=compute_cm(y_test,pred_nmc);

pred_lda=ones(size(Q_lda));
pred_lda(Q_lda<-b)=0;
r_lda=compute_cm(y_test,pred_lda);

perf(1,1)=compute_metric(r_nmc,"AUC");
perf(2,1)=compute_metric(r_lda,"AUC");

perf(1,2)=compute_metric(r_nmc,"AUPR");
perf(2,2)=compute_metric(r_lda,"AUPR");

perf(1,3)=compute_metric(r_nmc,"Fscore");
perf(2,3)=compute_metric(r_lda,"Fscore");

perf(1,4)=compute_metric(r_nmc,"ACscore");
perf(2,4)=compute_metric(r_lda,"ACscore");

perf(1,5)=compute_metric(r_nmc,"acc");
perf(2,5)=compute_metric(r_lda,"acc");

perf(1,6)=compute_metric(r_nmc,"MCC");
perf(2,6)=compute_metric(r_lda,"MCC");

perf(1,7)=compute_metric(r_nmc,"sens");
perf(2,7)=compute_metric(r_lda,"sens");

perf(1,8)=compute_metric(r_nmc,"spec");
perf(2,8)=compute_metric(r_lda,"spec");

prec_nmc=r_nmc.tp/(r_nmc.tp+r_nmc.fp);
prec_lda=r_lda.tp/(r_lda.tp+r_lda.fp);
perf(1,9)=prec_nmc;
perf(2,9)=prec_lda;

prec_nmc_n=r_nmc.tn/(r_nmc.tn+r_nmc.fn);
prec_lda_n=r_lda.tn/(r_lda.tn+r_lda.fn);
perf(1,10)=prec_nmc_n;
perf(2,10)=prec_lda_n;

perf(1,11)=compute_metric(r_nmc,'GM');
perf(2,11)=compute_metric(r_lda,'GM');


perf_diff=perf(1,:)-perf(2,:);
[~,idx]=sort(perf_diff,'descend');

bar1=bar([1:3,5:nm+1],perf(:,idx),0.7,'FaceColor','flat');
bar1(1).CData = repmat([0.9,0.1,0.1],nm,1);
bar1(2).CData = repmat([0.6,0.6,0.6],nm,1);

ax=gca;
ylim(0:1)
plot([4,4],ax.YLim,'k--','LineWidth',0.5*MAG,'Tag','Anno1')
legend(["NMC","LDA"])
xticks([1:3,5:nm+1])
STR_metrics=["AUROC (BA)","AUPR","F-score","AC-score","acc","MCC","sensitivity","specificity","precision (P)","precision (N)","GM"];
xticklabels(STR_metrics(idx))
xlabel("Evaluation metrics")
ylabel("Performance")
t4=title("{\rm Neg\_samples=1500, Pos\_samples=4500}");
t4.Position(2)=t4.Position(2)+0.005;

subplot(2,3,1)
text(0.2,0.09,['Neg\_NMC=',num2str(r_nmc.tn+r_nmc.fn)],'color','r','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',6,'Tag','Preserved')
text(0.81,0.11,['Pos\_NMC=',num2str(r_nmc.tp+r_nmc.fp)],'color','r','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',6,'Tag','Preserved')
text(0.2,0.08,['Neg\_LDA=',num2str(r_lda.tn+r_lda.fn)],'color',0.4*[1 1 1],'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',6,'Tag','Preserved')
text(0.81,0.1,['Pos\_LDA=',num2str(r_lda.tp+r_lda.fp)],'color',0.4*[1 1 1],'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',6,'Tag','Preserved')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot(2,3,2), hold on

p=4500/6000;
histogram(Q_nmc(bin.y_test==1),0:0.025:1,'Normalization','probability','FaceColor',[0.9,0.1,0.1],'FaceAlpha',0.8)
histogram(Q_lda(bin.y_test==1),0:0.025:1,'Normalization','probability','FaceColor',[0.6,0.6,0.6],'FaceAlpha',0.8)
plot([oop,oop],[0,0.2/p],'--','Color',[0.9,0.1,0.1],'LineWidth',1.5)
plot([-b,-b],[0,0.2/p],'--','Color',[0.6,0.6,0.6],'LineWidth',1.5)
text(oop+0.05,0.14/p,'OOP-NMC','Rotation',90)
text(-b-0.04,0.13/p,'LDA cut','Rotation',90)


xlim([0,1])
ylim([0,0.2/p])
yticks(linspace(0,0.2/p,5))
yticklabels([0,0.05,0.1,0.15,0.2])
ylabel("Probability")
xlabel("Normalized projection coordinates")
title("{\rm Pos\_samples=4500}")

text(0.03,0.1/p,['FN\_NMC=',num2str(r_nmc.fn)],'color','r','HorizontalAlignment','left','VerticalAlignment','middle','FontSize',6,'Tag','Preserved')
text(0.57,0.1/p,['TP\_NMC=',num2str(r_nmc.tp)],'color','r','HorizontalAlignment','left','VerticalAlignment','middle','FontSize',6,'Tag','Preserved')
text(0.03,0.09/p,['FN\_LDA=',num2str(r_lda.fn)],'color',0.4*[1 1 1],'HorizontalAlignment','left','VerticalAlignment','middle','FontSize',6,'Tag','Preserved')
text(0.57,0.09/p,['TP\_LDA=',num2str(r_lda.tp)],'color',0.4*[1 1 1],'HorizontalAlignment','left','VerticalAlignment','middle','FontSize',6,'Tag','Preserved')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot(2,3,3), hold on

p=1500/6000;
histogram(Q_nmc(bin.y_test==0),0:0.025:1,'Normalization','probability','FaceColor',[0.9,0.1,0.1],'FaceAlpha',0.8)
histogram(Q_lda(bin.y_test==0),0:0.025:1,'Normalization','probability','FaceColor',[0.6,0.6,0.6],'FaceAlpha',0.8)
plot([oop,oop],[0,0.2/p],'--','Color',[0.9,0.1,0.1],'LineWidth',1.5)
plot([-b,-b],[0,0.2/p],'--','Color',[0.6,0.6,0.6],'LineWidth',1.5)
text(oop+0.04,0.13/p,'OOP-NMC','Rotation',90)
text(-b-0.04,0.13/p,'LDA cut','Rotation',90)


xlim([0,1])
ylim([0,0.2/(p)])
yticks(linspace(0,0.2/(p),5))
yticklabels([0,0.05,0.1,0.15,0.2])
ylabel("Probability")
xlabel("Normalized projection coordinates")
title("{\rm Neg\_samples=1500}")

text(0.03,0.1/p,['TN\_NMC=',num2str(r_nmc.tn)],'color','r','HorizontalAlignment','left','VerticalAlignment','middle','FontSize',6,'Tag','Preserved')
text(0.55,0.1/p,['FP\_NMC=',num2str(r_nmc.fp)],'color','r','HorizontalAlignment','left','VerticalAlignment','middle','FontSize',6,'Tag','Preserved')
text(0.03,0.09/p,['TN\_LDA=',num2str(r_lda.tn)],'color',0.4*[1 1 1],'HorizontalAlignment','left','VerticalAlignment','middle','FontSize',6,'Tag','Preserved')
text(0.55,0.09/p,['FP\_LDA=',num2str(r_lda.fp)],'color',0.4*[1 1 1],'HorizontalAlignment','left','VerticalAlignment','middle','FontSize',6,'Tag','Preserved')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


load outputs.mat
bin = data.balanced;
outputs = outputs.balanced;

Q_nmc=bin.x_test*outputs.nmc.v';
oop=outputs.nmc.oop-min(Q_nmc);
Q_nmc=Q_nmc-min(Q_nmc);
oop=oop/max(Q_nmc);
Q_nmc=Q_nmc/max(Q_nmc);

Q_lda=bin.x_test*outputs.lda.v(1:end-1);
b=outputs.lda.v(end)+min(Q_lda);
Q_lda=Q_lda-min(Q_lda);
b=b/max(Q_lda);
Q_lda=Q_lda/max(Q_lda);


subplot(2,3,5), hold on

nm=11;

y_test=bin.y_test;
y_test(y_test == 2) = 0;

pred_nmc=ones(size(Q_nmc));
pred_nmc(Q_nmc<oop)=0;
r_nmc=compute_cm(y_test,pred_nmc);

pred_lda=ones(size(Q_lda));
pred_lda(Q_lda<-b)=0;
r_lda=compute_cm(y_test,pred_lda);

perf(1,1)=compute_metric(r_nmc,"AUC");
perf(2,1)=compute_metric(r_lda,"AUC");

perf(1,2)=compute_metric(r_nmc,"AUPR");
perf(2,2)=compute_metric(r_lda,"AUPR");

perf(1,3)=compute_metric(r_nmc,"Fscore");
perf(2,3)=compute_metric(r_lda,"Fscore");

perf(1,4)=compute_metric(r_nmc,"ACscore");
perf(2,4)=compute_metric(r_lda,"ACscore");

perf(1,5)=compute_metric(r_nmc,"acc");
perf(2,5)=compute_metric(r_lda,"acc");

perf(1,6)=compute_metric(r_nmc,"MCC");
perf(2,6)=compute_metric(r_lda,"MCC");

perf(1,7)=compute_metric(r_nmc,"sens");
perf(2,7)=compute_metric(r_lda,"sens");

perf(1,8)=compute_metric(r_nmc,"spec");
perf(2,8)=compute_metric(r_lda,"spec");

prec_nmc=r_nmc.tp/(r_nmc.tp+r_nmc.fp);
prec_lda=r_lda.tp/(r_lda.tp+r_lda.fp);
perf(1,9)=prec_nmc;
perf(2,9)=prec_lda;

prec_nmc_n=r_nmc.tn/(r_nmc.tn+r_nmc.fn);
prec_lda_n=r_lda.tn/(r_lda.tn+r_lda.fn);
perf(1,10)=prec_nmc_n;
perf(2,10)=prec_lda_n;

perf(1,11)=compute_metric(r_nmc,'GM');
perf(2,11)=compute_metric(r_lda,'GM');


perf_diff=perf(1,:)-perf(2,:);
[~,idx]=sort(perf_diff,'descend');

bar1=bar(1:nm,perf(:,idx),0.7,'FaceColor','flat');
bar1(1).CData = repmat([0.9,0.1,0.1],nm,1);
bar1(2).CData = repmat([0.6,0.6,0.6],nm,1);

ylim(0:1)
xticks(1:nm)
STR_metrics=["AUROC (BA)","AUPR","F-score","AC-score","acc","MCC","sensitivity","specificity","precision (P)","precision (N)","GM"];
xticks(1:nm)
xticklabels(setdiff(STR_metrics(idx),"AUmROC",'stable'))
xlabel("Evaluation metrics")
ylabel("Performance")
t5=title("{\rm Neg\_samples=1500, Pos\_samples=1500}");
t5.Position(2)=t5.Position(2)+0.005;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


load outputs.mat
bin = data.reverse_unbalanced;
outputs = outputs.reverse_unbalanced;

Q_nmc=bin.x_test*outputs.nmc.v';
oop=outputs.nmc.oop-min(Q_nmc);
Q_nmc=Q_nmc-min(Q_nmc);
oop=oop/max(Q_nmc);
Q_nmc=Q_nmc/max(Q_nmc);

Q_lda=bin.x_test*outputs.lda.v(1:end-1);
b=outputs.lda.v(end)+min(Q_lda);
Q_lda=Q_lda-min(Q_lda);
b=b/max(Q_lda);
Q_lda=Q_lda/max(Q_lda);


subplot(2,3,6), hold on

nm=11;

y_test=bin.y_test;
y_test(y_test == 2) = 0;

pred_nmc=ones(size(Q_nmc));
pred_nmc(Q_nmc<oop)=0;
r_nmc=compute_cm(y_test,pred_nmc);

pred_lda=ones(size(Q_lda));
pred_lda(Q_lda<-b)=0;
r_lda=compute_cm(y_test,pred_lda);

perf(1,1)=compute_metric(r_nmc,"AUC");
perf(2,1)=compute_metric(r_lda,"AUC");

perf(1,2)=compute_metric(r_nmc,"AUPR");
perf(2,2)=compute_metric(r_lda,"AUPR");

perf(1,3)=compute_metric(r_nmc,"Fscore");
perf(2,3)=compute_metric(r_lda,"Fscore");

perf(1,4)=compute_metric(r_nmc,"ACscore");
perf(2,4)=compute_metric(r_lda,"ACscore");

perf(1,5)=compute_metric(r_nmc,"acc");
perf(2,5)=compute_metric(r_lda,"acc");

perf(1,6)=compute_metric(r_nmc,"MCC");
perf(2,6)=compute_metric(r_lda,"MCC");

perf(1,7)=compute_metric(r_nmc,"sens");
perf(2,7)=compute_metric(r_lda,"sens");

perf(1,8)=compute_metric(r_nmc,"spec");
perf(2,8)=compute_metric(r_lda,"spec");

prec_nmc=r_nmc.tp/(r_nmc.tp+r_nmc.fp);
prec_lda=r_lda.tp/(r_lda.tp+r_lda.fp);
perf(1,9)=prec_nmc;
perf(2,9)=prec_lda;

prec_nmc_n=r_nmc.tn/(r_nmc.tn+r_nmc.fn);
prec_lda_n=r_lda.tn/(r_lda.tn+r_lda.fn);
perf(1,10)=prec_nmc_n;
perf(2,10)=prec_lda_n;

perf(1,11)=compute_metric(r_nmc,'GM');
perf(2,11)=compute_metric(r_lda,'GM');


perf_diff=perf(1,:)-perf(2,:);
[~,idx]=sort(perf_diff,'descend');

bar1=bar([1:9,11:nm+1],perf(:,idx),0.7,'FaceColor','flat');
bar1(1).CData = repmat([0.9,0.1,0.1],nm,1);
bar1(2).CData = repmat([0.6,0.6,0.6],nm,1);

ax=gca;
ylim(0:1)
plot([10,10],ax.YLim,'k--','LineWidth',0.5*MAG,'Tag','Anno1')
xticks([1:9,11:nm+1])
STR_metrics=["AUROC (BA)","AUPR","F-score","AC-score","acc","MCC","sensitivity","specificity","precision (P)","precision (N)","GM"];
xticklabels(STR_metrics(idx))
xlabel("Evaluation metrics")
ylabel("Performance")
t6=title("{\rm Neg\_samples=1500, Pos\_samples=500}");
t6.Position(2)=t6.Position(2)+0.005;



%%
set([findall(gcf,'type','line')],'LineWidth',1.15*MAG)
set([findall(gcf,'type','axes')],'FontSize',7*MAG)
set([findall(gcf,'type','axes')],'FontName',"Arial")
set([setdiff(findall(gcf,'type','text'),findall(gcf,'Tag','Preserved'))],'FontSize',7*MAG)
set([findall(gcf,'type','text')],'FontName',"Arial")
set([findall(gcf,'Tag','Anno1')],'LineWidth',0.5*MAG)

f1.Position(3:4)=[18,12]*MAG;


%%
function cm = compute_cm(y,y_pred)
cm.tp = sum(y_pred == 1 & y == 1);
cm.tn = sum(y_pred == 0 & y == 0);
cm.fp = sum(y_pred == 1 & y == 0);
cm.fn = sum(y_pred == 0 & y == 1);
end