function [Idiscrim] = filter_frame(I)
    
    % precautions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    I = double(I);
    
    % filter ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    [W2, J] = wavelets(I); %1st and 2nd wavelet filtering
    stdJ1 = std(W2(:), 'omitnan');

    Idiscrim = J/stdJ1;

end
