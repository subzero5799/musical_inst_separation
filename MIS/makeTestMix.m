function [mix, refMelodic, refPercussive, fs] = makeTestMix(fs, dur)
% Synthetic drums+melody mixture with exact ground truth

if nargin < 1 || isempty(fs),  fs  = 22050; end
if nargin < 2 || isempty(dur), dur = 8;     end

N = round(dur*fs);
t = (0:N-1)'/fs;

% melodic: sustained notes with a few harmonics
notes  = [220 277.18 329.63 440 329.63 277.18];   % A C# E A E C#
noteLen = dur/numel(notes);
refMelodic = zeros(N,1);
for k = 1:numel(notes)
    i0 = round((k-1)*noteLen*fs) + 1;
    i1 = min(round(k*noteLen*fs), N);
    idx = (i0:i1)';
    tt  = (idx - i0)/fs;
    env = min(tt/0.05, 1) .* exp(-tt/2.5);        
    tone = zeros(size(tt));
    for h = 1:4
        tone = tone + (1/h) * sin(2*pi*notes(k)*h*tt);
    end
    refMelodic(idx) = refMelodic(idx) + env .* tone;
end

% percussive: kick and snare on a simple pattern
refPercussive = zeros(N,1);
beat = 0.5;                                        % 120 BPM
rng(0);
for b = 0:floor(dur/beat)-1
    i0 = round(b*beat*fs) + 1;
    L  = min(round(0.25*fs), N-i0);
    if L < 10, continue; end
    idx = (i0:i0+L-1)';
    tt  = (0:L-1)'/fs;
    if mod(b,2) == 0
        hit = sin(2*pi*60*tt) .* exp(-tt/0.06);    % kick
    else
        hit = randn(L,1) .* exp(-tt/0.04);         % snare
    end
    refPercussive(idx) = refPercussive(idx) + hit;
end

%  normalise and mix
refMelodic    = 0.7 * refMelodic    / max(abs(refMelodic));
refPercussive = 0.7 * refPercussive / max(abs(refPercussive));

mix = refMelodic + refPercussive;
g   = max(abs(mix));
mix = mix / g;
refMelodic    = refMelodic    / g;      % keep the mix = sum of refs
refPercussive = refPercussive / g;

end