function x = myIstft(X, winLen, hop, winType, origLen)
% Inverse STFT by weighted overlap add

w = makeWindow(winType, winLen);
[nBins, numFrames] = size(X);
assert(nBins == winLen/2 + 1, 'myIstft: X rows do not match winLen.');

padLen = winLen;
outLen = (numFrames - 1)*hop + winLen;

num = zeros(outLen, 1);
den = zeros(outLen, 1);

for m = 1:numFrames
    spec  = [ X(:,m) ; conj(X(nBins-1 : -1 : 2, m)) ];
    frame = real(ifft(spec));

    idx      = (m-1)*hop + (1:winLen);
    num(idx) = num(idx) + frame .* w;
    den(idx) = den(idx) + w.^2;
end

den(den < 1e-12) = 1e-12;
xfull = num ./ den;

x = xfull(padLen + (1:origLen));

end