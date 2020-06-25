function [jumpPos, jumpMag] = findJumps(inData)
    arguments
        inData (:,1) {mustBeNumeric,mustBeNonempty,mustBeReal}
    end

    avg = mean(inData, "ommtnan")

end

