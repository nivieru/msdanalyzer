function Y = roundTimes(obj,X)
    if obj.time_sep > 0
        Y = msdanalyzer.roundSep(X, obj.time_sep);
    else
        Y = msdanalyzer.roundn(X, obj.TOLERANCE);
    end
end