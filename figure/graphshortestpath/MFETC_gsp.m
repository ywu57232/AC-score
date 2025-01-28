dbstop if error

rng(10086)
List_N=2.^(0:5)*1e3;
for i=1:6
    for repeat=1:6    
        N = List_N(i);
        m = 50;
        T = 0.1;
        gamma = 3;
        plot_flag = 0;
        distr = 4;

        [x_nPSO1, coords_nPSO1, comm_nPSO1, d_nPSO1] = nPSO_model(N, m, T, gamma, distr, plot_flag);

        rng(10086+10*i+repeat)
        rp=randperm(N);
        idx_start=rp(1);
        idx_end=rp(2);

        tic
        % only matlab 2021b and before support
        graphshortestpath(x_nPSO1,idx_start,idx_end,"Method","BFS",'Directed',false);
        t(repeat,i,1)=toc;

        tic
        % only matlab 2021b and before support
        graphshortestpath(x_nPSO1,idx_start,idx_end,"Method","Dijkstra",'Directed',false);
        t(repeat,i,2)=toc;

        tic
        naive_dijkstra(x_nPSO1,idx_start,idx_end);
        t(repeat,i,3)=toc;    
    end
end
t=t(2:end,:,:);
N = List_N;


MAG=1;
f1=figure(1);
set(f1,'Resize',true)
f1.Units='centimeters';
f1.Position(3:4)=[18,8]*MAG;

sa1=subplot(1,2,1);
hold on

options.handle     = figure(1);
options.alpha      = 0.5;
options.line_width = 0.75;
options.error      = 'std'; 
options.x_axis     = N/N(1);
alpha=0.45;

etc = t(:,:,1) ./ t(:,1,1);
m=mean(etc,1);
options.color_line = [1 0 0]*0.7;
options.color_area = options.color_line * (1-alpha) +[1 1 1]*alpha;
error_curve(etc,options);
plot(N/N(1),m,'o','LineWidth',1.25,'MarkerSize',5,'Color',options.color_line,'Tag','point')

etc = t(:,:,2) ./ t(:,1,2);
m=mean(etc,1);
options.color_line = [1 0 1]*0.7;
options.color_area = options.color_line * (1-alpha) +[1 1 1]*alpha;
error_curve(etc,options);
plot(N/N(1),m,'o','LineWidth',1.25,'MarkerSize',5,'Color',options.color_line,'Tag','point')

etc = t(:,:,3) ./ t(:,1,3);
m=mean(etc,1);
options.color_line = [0 1 0]*0.7;
options.color_area = options.color_line * (1-alpha) +[1 1 1]*alpha;
error_curve(etc,options);
plot(N/N(1),m,'o','LineWidth',1.25,'MarkerSize',5,'Color',options.color_line,'Tag','point')


LW_ref=0.75;
Cl_ref=[1,1,1]*0.5;
plot([1,N(end)/N(1)],[1,N(end)/N(1)],'--','Color',Cl_ref,'LineWidth',LW_ref,'Tag','ref')
plot([1,N(end)/N(1)],[1,N(end)/N(1)].^2,'--','Color',Cl_ref,'LineWidth',LW_ref,'Tag','ref')
plot([1,N(end)/N(1)],[1,N(end)/N(1)].^3,'--','Color',Cl_ref,'LineWidth',LW_ref,'Tag','ref')
NLogComplx=@(k,N) k*N.*log(k*N)/(N*log(N));
xNLogComplx=logspace(log10(1),log10(N(end)/N(1)),20);
plot(xNLogComplx,NLogComplx(xNLogComplx,1e3),'--','Color',Cl_ref,'LineWidth',LW_ref,'Tag','ref')

grid on
sa1.XMinorGrid='off';
sa1.XScale='log';
sa1.YScale='log';
xlim([1,2^5])
ylim([1,2^10])
xticks(2.^(0:5))
xticklabels(["1","2","2^2","2^3","2^4","2^5"])
yticks(2.^(0:10))
yticklabels(["1","","","2^3","","","2^6","","","2^9",""])
xlabel({'Number of times as the smallest ','network size {N_0} (N_0=1000)','({\itE} is set proportional to {\itN})'})
ylabel("{ETC}")


sa2=subplot(1,2,2);
hold on

options.handle     = figure(1);
options.alpha      = 0.5;
options.line_width = 0.75;
options.error      = 'std'; 
options.x_axis     = N;

m=mean(t(:,:,1),1);
options.color_line = [1 0 0]*0.7;
options.color_area = options.color_line * (1-alpha) +[1 1 1]*alpha;
error_curve(t(:,:,1),options);
plot(N,m,'o','LineWidth',1.25,'MarkerSize',5,'Color',options.color_line,'Tag','point')

m=mean(t(:,:,2),1);
options.color_line = [1 0 1]*0.7;
options.color_area = options.color_line * (1-alpha) +[1 1 1]*alpha;
error_curve(t(:,:,2),options);
plot(N,m,'o','LineWidth',1.25,'MarkerSize',5,'Color',options.color_line,'Tag','point')

m=mean(t(:,:,3),1);
options.color_line = [0 1 0]*0.7;
options.color_area = options.color_line * (1-alpha) +[1 1 1]*alpha;
error_curve(t(:,:,3),options);
plot(N,m,'o','LineWidth',1.25,'MarkerSize',5,'Color',options.color_line,'Tag','point')

grid on
sa2.XMinorGrid='off';
sa2.XScale='log';
sa2.YScale='log';
xlabel('Number of nodes {\itN} in the network')
xticks(List_N)
yticks(10.^(-3:1:4))
sa2.YTickLabel(4)={'1'};
sa2.YTickLabel(5)={'10'};
ylabel("{ Running time} {\it t} (s)")

legend("","graphshortest path (BFS)","","","graphshortest path (Dijkstra)","","","native Dijkstra algorithm","")
annotation('textbox',[0.3300,0.8706,0.1,0.1176],'String','$O(N^3$)','LineStyle','none','FontSize',7,'FontName','Null','Interpreter','latex','Tag','latex')
annotation('textbox',[0.4625,0.8706,0.1,0.1176],'String','$O(N^{2}$)','LineStyle','none','FontSize',7,'Interpreter','latex','Tag','latex')
annotation('textbox',[0.4625,0.5153,0.1,0.1176],'String','$O(N{\rm log}N$)','LineStyle','none','FontSize',7,'Interpreter','latex','Tag','latex')
annotation('textbox',[0.4625,0.4624,0.1,0.1176],'String','$O(N$)','LineStyle','none','FontSize',7,'Interpreter','latex','Tag','latex')


%%
set([findall(gcf,'type','line')],'LineWidth',0.6)
set([findall(gcf,'type','axes')],'FontSize',7)
set([findall(gcf,'type','axes')],'FontName',"Arial")
set([findall(gcf,'type','text')],'FontSize',7)
set([findall(gcf,'type','text')],'FontName',"Arial")

set([findobj(f1,'Tag','point')],'LineWidth',1)
set([findobj(f1,'Tag','mean')],'LineWidth',1.5)
set([findobj(f1,'Tag','ref')],'LineWidth',1.0)

