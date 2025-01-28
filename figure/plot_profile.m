

tpr=0:0.01:1;
tnr=0:0.01:1;

for i=1:101
    for j=1:101
        gm(i,j) = sqrt(tpr(i)*tnr(j));
        ac_score(i,j) = 2*tpr(i)*tnr(j)/(tpr(i)+tnr(j));
        roc(i,j)=1/2*(tpr(i)+tnr(j));
    end
end

ax=axes();
hold on
box on
grid on
view([90,0])
s2=surf(tpr,tnr,ac_score,'FaceColor','#CC0000','FaceAlpha',1,'EdgeColor','#004C00','LineStyle','none');
s1=surf(tpr,tnr,gm,'FaceColor','#00CC00','FaceAlpha',1,'EdgeColor','#4C0000','LineStyle','none');
s3=surf(tpr,tnr,roc,'FaceColor','#0000CC','FaceAlpha',1,'EdgeColor','#00004C','LineStyle','none');
legend("AC-score","GM","AUROC(and balanced accuracy)")
xlim([-0.1,1.1])
ylim([-0.1,1.1])
zlim([-0.1,1.1])
xlabel("TPR")
ylabel("TNR")
zlabel("AC-score")

C=0.7;
p(1)=patch(C*[1,0,0,1]-(C-1)/2,[1,1,1,1],min(C*[0,0,1,1]-(C-1)/2,[ax.YLim(1),ax.YLim(1),Inf,Inf]),0.6*[1 1 1],'FaceAlpha',0.35,'EdgeAlpha',0);
p(2)=patch(C*[1,0,0,1]-(C-1)/2,0.5*[1,1,1,1],min(C*[0,0,1,1]-(C-1)/2,[ax.YLim(1),ax.YLim(1),Inf,Inf]),0.6*[1 1 1],'FaceAlpha',0.35,'EdgeAlpha',0);
p(3)=patch(C*[1,0,0,1]-(C-1)/2,0*[1,1,1,1],min(C*[0,0,1,1]-(C-1)/2,[ax.YLim(1),ax.YLim(1),Inf,Inf]),0.6*[1 1 1],'FaceAlpha',0.35,'EdgeAlpha',0);

p(4)=patch([1,1,1,1],C*[1,0,0,1]-(C-1)/2,min(C*[0,0,1,1]-(C-1)/2,[ax.YLim(1),ax.YLim(1),Inf,Inf]),0.6*[1 1 1],'FaceAlpha',0.35,'EdgeAlpha',0);
p(5)=patch(0.5*[1,1,1,1],C*[1,0,0,1]-(C-1)/2,min(C*[0,0,1,1]-(C-1)/2,[ax.YLim(1),ax.YLim(1),Inf,Inf]),0.6*[1 1 1],'FaceAlpha',0.35,'EdgeAlpha',0);
p(6)=patch(0*[1,1,1,1],C*[1,0,0,1]-(C-1)/2,min(C*[0,0,1,1]-(C-1)/2,[ax.YLim(1),ax.YLim(1),Inf,Inf]),0.6*[1 1 1],'FaceAlpha',0.35,'EdgeAlpha',0);
set(p,'HandleVisibility','off')