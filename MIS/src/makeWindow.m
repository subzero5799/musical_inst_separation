% Periodic window, N x 1. Periodic (divide by N) not symmetric (N-1), since only the periodic form overlap-adds to a constant.
function w = makeWindow(winType, N)

n = (0:N-1)';

switch lower(winType)
    case 'hann'
        w = 0.5 - 0.5 * cos(2*pi*n/N);
    case 'hamming'
        w = 0.54 - 0.46 * cos(2*pi*n/N);
    case 'rect'
        w = ones(N,1);
    otherwise
        error('makeWindow: unknown window type "%s".', winType);
end

end