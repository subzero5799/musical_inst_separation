function [xh, xp, S, Mh] = separate(x, fs, cfg)
% Full HPS pipeline: STFT -> median filters -> masks -> ISTFT.

X = myStft(x, fs, cfg.winLen, cfg.hop, cfg.winType);
S = abs(X);

frameRate = fs / cfg.hop;              % frames per second
binWidth  = fs / cfg.winLen;           % Hz per bin

Lh = 2*floor(cfg.Lh_ms/1000 * frameRate / 2) + 1;   % frames
Lp = 2*floor(cfg.Lp_hz / binWidth / 2) + 1;         % bins
Lh = max(Lh, 3);
Lp = max(Lp, 3);

[Mh, Mp] = hpsMasks(S, Lh, Lp, cfg.maskType, cfg.maskPower);

xh = myIstft(Mh .* X, cfg.winLen, cfg.hop, cfg.winType, numel(x));
xp = myIstft(Mp .* X, cfg.winLen, cfg.hop, cfg.winType, numel(x));

end