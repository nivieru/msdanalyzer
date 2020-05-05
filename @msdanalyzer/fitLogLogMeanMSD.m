function  varargout = fitLogLogMeanMSD(obj, indices, clip_factor)
%%FITMEANMSD Fit the weighted averaged MSD by a linear function.
%
% obj.fitMeanMSD computes and fits the weighted mean MSD by a
% straight line y = a * x. The fit is therefore valid only for
% purely diffusive behavior. Fit results are displayed in the
% command window.
%
% obj.fitMeanMSD(indices) only takes into account the MSD
% curves with the specified indices. An empty indices vector specifies all indices.
%
% obj.fitMeanMSD(indices, clip_factor) does the fit, taking into account
% only the potion of the average MSD curve specified by 'clip_factor'.
% clip_factor can be a single elemnt specifying the end of the portion, 
% or a two element vector [begin end], specifying also the start of the portion.
% if the values of clip_factor are doubles between 0 and 1 they are taken as a
% fraction of the curve length. If the values exceed 1, then the clip factor is understood
% to be the indices of points (minus one) to take into account in the fit. By
% default, it is set to 0.25.
%
% [fo, gof] = obj.fitMeanMSD(...) returns the fit object and the
% goodness of fit.

if nargin < 3
    clip_factor = 0.25;
end

if nargin < 2
    indices = [];
end

if ~obj.msd_valid
    obj = obj.computeMSD;
end

ft = fittype('poly1');
mmsd = obj.getMeanMSD(indices);

t = mmsd(:,1);
y = mmsd(:,2);
w = 1./mmsd(:,3);

% Clip data, never take the first one dt = 0
if length(clip_factor) > 1
    if clip_factor(2) < 1
        t_limit = max(2, round(numel(t) * clip_factor(1))) : round(numel(t) * clip_factor(2));
    else
        t_limit = max(2, 1 + clip_factor(1)) : min(1+round(clip_factor), numel(t));
    end
else
    if clip_factor < 1
        t_limit = 2 : round(numel(t) * clip_factor);
    else
        t_limit = 2 : min(1+round(clip_factor), numel(t));
    end
end
t = t(t_limit);
y = y(t_limit);
w = w(t_limit);

[fo, gof] = fit(log(t), log(y), ft, 'Weights', w);

ci = confint(fo);
str = sprintf([
    'Estimating alpha through linear weighted fit of the log log mean MSD curve.\n', ...
    'alpha = %.3e with 95%% confidence interval [ %.3e - %.3e ].\n', ...
    'Goodness of fit: R² = %.3f.' ], ...
    fo.p1, ci(1), ci(2), gof.adjrsquare );
disp(str)

if nargout > 0
    varargout{1} = fo;
    if nargout > 1
        varargout{2} = gof;
    end
end

end
