function etc = ETC(alg, algDataGen, baseSize, numTest, repeat)
% a data-driven model-free and parameter-free method to account for the
% factors influencing an algorithm; for instance, the crosstalk between
% algorithm realization, compilation and hardware implementation. This can
% be used to guide code optimization and to gain algorithmic maximum
% efficiency for specific hardware, programming language or compiler. The
% values of ETC in function of an input variable form a curve that offers a
% visual representation of how an algorithm scale with input size. When the
% ETC curves of different versions of an algorithm are reported together
% with the theoretical time complexity curve, their comparison allows to
% select what versions are closer to the theoretical complexity.

% alg: Provide the algorithm to test for empirical scalability.
% algDataGen: Provide the algorithm to generate data for the tested algorithm with a argument of a single size.
% baseSize: The smallest dimensional size.
% numTest: Number of different input sizes to test runtimes and ETCs.
% repeat: Number of repetition for each input size.

Sizes = baseSize*2.^((1:numTest)-1);
for rp = 1:repeat + 1
    for k = 1:numTest
        data = algDataGen(Sizes(k));
        tic
        alg(data{:});
        t(rp,k) = toc;
    end
end
t = t(2:end,:);

etc = t ./ t(:,1);


%% plot
MAG=1;
f1=figure(1);
set(f1,'Resize',true)
f1.Units='centimeters';
f1.Position(3:4)=[18,8]*MAG;

options.handle     = figure(1);
options.alpha      = 0.5;
options.line_width = 0.75;
options.error      = 'std'; 
options.x_axis     = Sizes/Sizes(1);
alpha=0.45;
sa1 = subplot(1,2,1);

options.color_line = [0 0 1]*0.9;
options.color_area = options.color_line * (1-alpha) +[1 1 1]*alpha;
error_curve(etc,options);
plot(options.x_axis, mean(etc,1),'o','LineWidth',1.25,'MarkerSize',5,'Color',options.color_line,'Tag','point')

sa1.XScale='log';
sa1.YScale='log';
xlabel({'Number of times as the smallest input size'})
ylabel("{ETC}")

plot([1,Sizes(end)/Sizes(1)],[1,Sizes(end)/Sizes(1)],'k')
plot([1,Sizes(end)/Sizes(1)],[1,Sizes(end)/Sizes(1)].^2,'k')
plot([1,Sizes(end)/Sizes(1)],[1,Sizes(end)/Sizes(1)].^3,'k')


options.handle     = figure(1);
options.alpha      = 0.5;
options.line_width = 0.75;
options.error      = 'std'; 
options.x_axis     = Sizes;
alpha=0.45;
sa2 = subplot(1,2,2);

options.color_line = [0 0 1]*0.9;
options.color_area = options.color_line * (1-alpha) +[1 1 1]*alpha;
error_curve(t,options);
plot(Sizes,t,'o','LineWidth',1.25,'MarkerSize',5,'Color',options.color_line,'Tag','point')

sa2.XScale='log';
sa2.YScale='log';
xlabel('Input data dimensional size')
ylabel("{ Running time} {\it t} (s)")

end