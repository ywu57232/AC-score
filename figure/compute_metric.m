function s = compute_metric(r,metric)
if strcmp(metric,"AUPR2") || strcmp(metric,"Fscore2") % assume the previously negative class as positive 
    r = flipcm(r);
    s = compute_metric_wrapper(r,metric);
elseif strcmp(metric,"Fscore") || strcmp(metric,"AUPR") % assume the previously negative class as positive and take the average
    a = compute_metric_wrapper(r,metric);
    r = flipcm(r);
    b = compute_metric_wrapper(r,metric);
    s = mean([a,b],"omitnan"); 
else
    s = compute_metric_wrapper(r,metric);   % evaluation for positive class
end
end


function r = flipcm(r)  % flip both true labels and predicted labels to consider the previously negative as positive and vice versa.
tp=r.tp; tn=r.tn; fp=r.fp; fn=r.fn;
r.tp=tn; r.tn=tp; r.fp=fn; r.fn=fp;
end


function s = compute_metric_wrapper(r,metric)
if strcmp(metric,"AUPR1") || strcmp(metric,"AUPR2") || strcmp(metric,"AUPR")
    metric = 'AUPR_';
elseif strcmp(metric,"Fscore1") || strcmp(metric,"Fscore2") || strcmp(metric,"Fscore")
    metric = 'Fscore';
elseif strcmp(metric,"AUC")
    metric = 'AUC_';
end
s = do_compute_metric(r,metric);
end


function result = do_compute_metric(r,metric)
tp=r.tp; tn=r.tn; fp=r.fp; fn=r.fn;

if strcmp(metric, 'AUPR')
    result = compute_AUPR(markers, double(condition==1));
elseif strcmp(metric, 'acc')
    result = (tp + tn) / (tp + tn + fp + fn);
elseif strcmp(metric, 'prec')
    [tp,~,fp,~] = computeCM(condition,markers);
    result = tp/(tp+fp); %PPV;
elseif strcmp(metric, 'sens')
    result = tp/(tp+fn); %recall or TPR
elseif strcmp(metric, 'spec')
    result = tn/(tn+fp); %TNR
elseif strcmp(metric, 'AUC_')
    if tp==0 && fn==0
        sens=1;
    else
        sens = tp/(tp+fn);
    end
    if fp==0 && tn==0
        fpr=0;
    else
        fpr = fp/(fp+tn);        
    end
    
    x = [0;sens;1];
    y = [0;fpr;1];
    
    result = trapz(y,x);
elseif strcmp(metric, 'AUPR_')
    if tp==0 && fn==0
        sens=1;
    else
        sens = tp/(tp+fn);
    end
    if tp==0 && fp==0
        prec=0;
    else
        prec = tp/(tp+fp);
    end
    
    x = [0;sens;1];
    y = [1;prec;0];
    
    result = trapz(x,y);
elseif strcmp(metric, 'Fscore')
    if (tp==0 && fn==0) || (tp==0 && fp==0)
        result = 0;
    else
        if tp==0 && fn==0
            sens=1;
        else
            sens = tp/(tp+fn);
        end
        if tp==0 && fp==0
            prec=0;
        else
            prec = tp/(tp+fp);
        end
        if sens==0 && prec==0
            result = 0;
        else
            result = (2*prec*sens)/(prec+sens);
        end
    end
elseif strcmp(metric, 'MCC')
    if (tp == 0 && fp == 0) || (tn == 0 && fn == 0)
        result = 0;
    else
        result = (tp*tn - fp*fn) / sqrt((tp+fp)*(tp+fn)*(tn+fp)*(tn+fn)) ;
    end 
elseif strcmp(metric, 'ACscore')
    if tp==0 && fn==0
        sens = 0;
    else
        sens = tp/(tp+fn);
    end
    if fp==0 && tn==0
        spc = 0;
    else
        spc = tn/(fp+tn);
    end
    if sens == 0 && spc == 0
        result = 0;
    else
        result = 2*sens*spc/(sens+spc);
    end
elseif strcmp(metric, 'GM')
    if tp==0 && fn==0
        sens = 0;
    else
        sens = tp/(tp+fn);
    end
    if fp==0 && tn==0
        spc = 0;
    else
        spc = tn/(fp+tn);
    end
    result = sqrt(sens*spc);
end
end