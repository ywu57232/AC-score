N=1E3;
rng(10086)
markers=randperm(N);
labels=cellstr([repmat({"red"},1,N/2-1),{"green"},{"red"},repmat({"green"},1,N/2-1)]);
[ACscore, ACscoreArray, bestCut, direction, bestPredicted]=computeACscore(labels, markers,char("green"));
[~,idx]=sort(markers);
plot(ACscoreArray(idx));
xlabel("Marker ranking")
ylabel("ACscore")
disp(['ACscore: ', num2str(ACscore)])
disp(['bestCut: ', num2str(bestCut)])