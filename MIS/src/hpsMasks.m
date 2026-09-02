% harmonic/percussive masks from a magnitude spectrogram.
% Lh: median filter length along time, in FRAMES
% Lp: median filter length along frequency, in BINS
function [Mh, Mp] = hpsMasks(S, Lh, Lp, maskType, p)

H = medianFilt2(S, Lh, 2);      % smooth along time  -> harmonic estimate
P = medianFilt2(S, Lp, 1);      % smooth along freq  -> percussive estimate

switch lower(maskType)
    case 'binary'
        Mh = double(H > P);
        Mp = 1 - Mh;
    case 'soft'
        Hp = H.^p;
        Pp = P.^p;
        d  = Hp + Pp + eps;
        Mh = Hp ./ d;
        Mp = Pp ./ d;
    otherwise
        error('hpsMasks: unknown maskType "%s".', maskType);
end

end