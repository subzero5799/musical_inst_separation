% test to see quality of the reconstruction
clear; 
clc; 
close all;

thisDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisDir,'..'), fullfile(thisDir,'..','src'));
cfg = config();
fs  = cfg.fs;

n      = (0 : round(2*fs)-1)';
clicks = zeros(size(n));
clicks(1 : round(0.25*fs) : end) = 1;
sigA = 0.5*sin(2*pi*220*n/fs) + 0.3*sin(2*pi*1370*n/fs) + 0.4*clicks + 0.05*randn(size(n));
sigA = sigA / max(abs(sigA));

S    = load('handel.mat');
sigB = S.y(:) / max(abs(S.y));

signals  = {sigA, sigB};
names    = {'synthetic','handel'};
winLens  = [512 1024 2048];
overlaps = [0.50 0.75];

fprintf('\n%-11s %8s %8s %14s %12s   %s\n', ...
        'signal','winLen','overlap','maxAbsErr','relErr(dB)','result');
fprintf('%s\n', repmat('-',1,72));

allPassed = true;
for s = 1:numel(signals)
    x = signals{s};
    for wi = 1:numel(winLens)
        for oi = 1:numel(overlaps)
            winLen = winLens(wi);
            hop    = round(winLen * (1 - overlaps(oi)));

            X  = myStft(x, fs, winLen, hop, cfg.winType);
            xr = myIstft(X, winLen, hop, cfg.winType, numel(x));

            maxErr = max(abs(x - xr));
            relDb  = 20*log10(norm(x - xr)/norm(x) + eps);
            passed = maxErr < cfg.reconTol;
            allPassed = allPassed && passed;

            if passed, res = 'PASS'; else, res = 'FAIL'; end
            fprintf('%-11s %8d %8.2f %14.3e %12.1f   %s\n', ...
                    names{s}, winLen, overlaps(oi), maxErr, relDb, res);
        end
    end
end

fprintf('%s\n', repmat('-',1,72));
if allPassed
    fprintf('M0 PASSED - STFT/ISTFT round trip is exact.\n\n');
else
    fprintf('M0 FAILED.\n\n');
end

X  = myStft(sigB, fs, cfg.winLen, cfg.hop, cfg.winType);
xr = myIstft(X, cfg.winLen, cfg.hop, cfg.winType, numel(sigB));
t  = (0:numel(sigB)-1)/fs;

figure('Name','M0 reconstruction error');
subplot(2,1,1);
plot(t, sigB); hold on; plot(t, xr, '--');
xlabel('Time (s)'); ylabel('Amplitude');
legend('original','reconstructed'); title('Overlay'); grid on;
subplot(2,1,2);
plot(t, sigB - xr);
xlabel('Time (s)'); ylabel('Error'); title('Reconstruction error'); grid on;

w   = makeWindow(cfg.winType, cfg.winLen);
nF  = 40;
den = zeros((nF-1)*cfg.hop + cfg.winLen, 1);
for m = 1:nF
    idx = (m-1)*cfg.hop + (1:cfg.winLen);
    den(idx) = den(idx) + w.^2;
end

figure('Name','COLA check');
plot(den); grid on;
xlabel('Sample'); ylabel('\Sigma w^2');
title(sprintf('Sum of squared %s windows, %d%% overlap', ...
      cfg.winType, round(100*cfg.overlap)));

fprintf('COLA plateau: %.4f (expected %.4f)\n\n', ...
        max(den), (cfg.winLen/cfg.hop)*3/8);