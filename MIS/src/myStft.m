function [X, f, t] = myStft(x, fs, winLen, hop, winType)
% STFT. Returns one-sided X of size (winLen/2+1) x numFrames, plus the frequency (Hz) and time (s) axes

x = x(:);
assert(isreal(x),          'myStft: x must be real.');
assert(mod(winLen,2) == 0, 'myStft: winLen must be even.');
assert(hop >= 1 && hop <= winLen, 'myStft: hop out of range.');

w = makeWindow(winType, winLen);

padLen = winLen;
xpad   = [zeros(padLen,1); x; zeros(padLen,1)];

numFrames = ceil((numel(xpad) - winLen) / hop) + 1;
xpad(end+1 : (numFrames-1)*hop + winLen) = 0;

nBins = winLen/2 + 1;
X     = zeros(nBins, numFrames);

for m = 1:numFrames
    idx    = (m-1)*hop + (1:winLen);
    frame  = xpad(idx) .* w;
    spec   = fft(frame);
    X(:,m) = spec(1:nBins);     % upper half is the conjugate mirror
end

f = (0:nBins-1)' * (fs / winLen);
t = ((0:numFrames-1)*hop + winLen/2 - padLen) / fs;

end