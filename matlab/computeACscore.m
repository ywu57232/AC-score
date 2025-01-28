function [ACscore, ACscoreArray, bestCut, direction, bestPredicted] = computeACscore(labels, markers, positiveClass)

% ACscore is a balanced metric for the evaluation of model's
% performance of binary classifiers, and for guiding their
% training, which is suitable for unbalanced data as well as on
% balanced data.

% ACscore = 2 * (sensitivity * specificity) / (sensitivity + specificity).

%%% Input  %%%
% labels: Groundtruth labels of data. Be a string cell, char cell, numeric cell,string array, numeric array,or logical array of 1 dimension.
% markers: Either predicted labels or scores from DR results. In the same format as labels.
% positiveClass: Assign one of the two classes as the positive class.

%%% Output %%%
% ACscore: The ACscore evaluation result. If markers are scores, this will be the highest one among the ACscore evaluations for N+1 possible cuts.
% ACscoreArray (only when markers are scores): ACscore evaluations for N+1 possible cuts.
% bestCut (only when markers are scores): The cut corresponding to the higest ACscore from the ACscore array, obtained as the middle point of the pair of scores closest to the cut and lying at each side of the cut (Except the cut is lower than the smallest score or higher than the largest score).
% direction: 1 if scores greater or equal to the bestCut are predicted as positive; 0 if scores greater or equal to the bestCut are predicted as negative;
% bestPredicted (only when markers are scores): The predicted labels corresponding to the higest ACscore evaluation from the ACscore array.

%%% An example to use %%%
% N=1E3;
% rng(10086)
% markers=randperm(N);
% labels=cellstr([repmat({"red"},1,N/2-1),{"green"},{"red"},repmat({"green"},1,N/2-1)]);
% [ACscore, ACscoreArray, bestCut, direction, bestPredicted]=computeACscore(labels, markers,char("green"));
% [~,idx]=sort(markers);
% plot(ACscoreArray(idx));
% xlabel("Marker ranking")
% ylabel("ACscore")
% disp(['ACscore: ', num2str(ACscore)])
% disp(['bestCut: ', num2str(bestCut)])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


validateattributes(labels,{'cell','numeric','string','logical'},{'vector'})
validateattributes(markers,{'cell','numeric','string','logical'},{'vector'})

if iscell(markers)
    IsMarkerScore = 0;
elseif numel(unique(markers))==2
    IsMarkerScore = 0;
else
    IsMarkerScore = 1;
end

if iscell(labels)
    if isnumeric(labels{1})
        labels = cellstr(string(cell2mat(labels)));
    elseif isstring(labels{1})
        labels = cellstr(labels);
    elseif ~ischar(labels{1})
        error('Input argument must be a string cell, char cell, numeric cell,string array, numeric array,or logical array in a row or column');
    end
    if ~IsMarkerScore
        if isnumeric(markers{1})
            markers = cellstr(string(cell2mat(markers)));
        elseif isstring(markers{1})
            markers = cellstr(markers);
        elseif ~ischar(markers{1})
            error('Input argument must be a string cell, char cell, numeric cell,string array, numeric array,or logical array in a row or column');
        end
    end
end

if size(labels,1)==1
    labels=labels';
    markers=markers';
end

List_labels = unique(labels,'stable');
if numel(List_labels)~=2
    error("The number of classes is not 2")
end
if isempty(intersect(List_labels,positiveClass))
    error("The positive class specified is incorrect")
end

negativeClass=setdiff(List_labels,positiveClass);
S = size(markers);
N = S(S~=1);
mapped_labels = zeros(N,1,'logical');
if ~iscell(labels)
    mapped_labels(labels==positiveClass,1) = 1; 
    mapped_labels(labels==negativeClass,1) = 0; 
    if ~IsMarkerScore
        mapped_markers(markers==positiveClass,1) = 1; 
        mapped_markers(markers==negativeClass,1) = 0;
    end
else 
    if ~iscell(positiveClass)
        positiveClass = {positiveClass};
    end
    mapped_labels(strcmp(labels,positiveClass{:}),1) = 1;
    mapped_labels(strcmp(labels,negativeClass{:}),1) = 0; 
    if ~IsMarkerScore
        mapped_markers(strcmp(markers,positiveClass{:}),1) = 1;
        mapped_markers(strcmp(markers,negativeClass{:}),1) = 0;
    end
end

if ~IsMarkerScore    % for predicted labels
    [tp,tn,fp,fn] = computeCM(mapped_labels,mapped_markers);
    ACscore = docomputeACscore(tp,tn,fp,fn);
else                 % for scores
    [~,idx_sorted] = sort(markers,'ascend');
    [idx_sorted_inv,~,~] = find((1:N)==idx_sorted);


    [ACscoreArrayForward,ACscoreForward,idx_max_forward]=computeACscoreUnidirect(mapped_labels(idx_sorted),'forward');
    [ACscoreArrayBackward,ACscoreBackward,idx_max_Backward]=computeACscoreUnidirect(mapped_labels(idx_sorted),'backward');

    if ACscoreForward >= ACscoreBackward
        ACscoreArray = ACscoreArrayForward(idx_sorted_inv);
        ACscore = ACscoreForward;
        idx_max = idx_max_forward;
        direction = 1;
    else
        ACscoreArray = ACscoreArrayBackward(idx_sorted_inv);
        ACscore = ACscoreBackward;
        idx_max = idx_max_Backward;
        direction = 0;
    end


    Delta = 1E-6;
    if idx_max==1
        bestCut = markers(idx_sorted(1)) - Delta;
    elseif idx_max==N+1
        bestCut = markers(idx_sorted(end)) + Delta;
    else
        bestCut = (markers(idx_sorted(idx_max-1)) + markers(idx_sorted(idx_max))) / 2; 
    end
    if direction == 1
        bestPredicted = [repmat(negativeClass,idx_sorted(idx_max)-1,1);repmat(positiveClass,N-(idx_sorted(idx_max)-1),1)];
    else
        bestPredicted = [repmat(positiveClass,idx_sorted(idx_max)-1,1);repmat(negativeClass,N-(idx_sorted(idx_max)-1),1)];
    end
end
end


function [ACscoreArray,ACscore,idx_max]=computeACscoreUnidirect(mapped_labels,dir)
N=length(mapped_labels);
if strcmp(dir,"forward")
    predicted = ones(N,1,'logical');
else
    predicted = zeros(N,1,'logical');
end
ACscoreArray = nan(N,1);

[tp,tn,fp,fn]=computeCM(mapped_labels,predicted);
ACscoreArray(1) = docomputeACscore(tp,tn,fp,fn);

for i=2:N+1     % N points have N+1 cut candidates
    if strcmp(dir,"forward")
        [tp,tn,fp,fn]=updateCM_forward(tp,tn,fp,fn,mapped_labels,i);
    else
        [tp,tn,fp,fn]=updateCM_backward(tp,tn,fp,fn,mapped_labels,i);
    end
    ACscoreArray(i) = docomputeACscore(tp,tn,fp,fn);
end
[ACscore,idx_max] = max(ACscoreArray);
end


function ACscore = docomputeACscore(tp,tn,fp,fn)
Total = tp+tn+fp+fn;
if (tp+tn)==Total
    ACscore=1;
elseif (fp+fn)==Total
    ACscore=0;
else
    tptn = tp*tn;
    ACscore = 2*tptn / (2*tptn+tp*fp+tn*fn);
end
end


function [tp,tn,fp,fn] = computeCM(labels,predicted)
tp = sum(predicted == 1 & labels == 1);
tn = sum(predicted == 0 & labels == 0);
fp = sum(predicted == 1 & labels == 0);
fn = sum(predicted == 0 & labels == 1);
end

function [tp,tn,fp,fn] = updateCM_forward(tp,tn,fp,fn,mapped_labels,i)
if mapped_labels(i-1)==0
    tn = tn + 1;
    fp = fp -1;
else
    tp = tp - 1;
    fn = fn + 1;
end
end

function [tp,tn,fp,fn] = updateCM_backward(tp,tn,fp,fn,mapped_labels,i)
if mapped_labels(i-1)==1
    tp = tp + 1;
    fn = fn -1;
else
    tn = tn - 1;
    fp = fp + 1;
end
end