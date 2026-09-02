% main.m - one full separation run

clear;
clc; 
close all;

here = fileparts(mfilename('fullpath'));
addpath(here, fullfile(here,'src'), fullfile(here,'eval'));
cfg = config();

outDir = fullfile(cfg.paths.results, 'audio');
figDir = fullfile(cfg.paths.results, 'figures');
if ~exist(outDir,'dir'), mkdir(outDir); end
if ~exist(figDir,'dir'), mkdir(figDir); end

% input
% 'stems' - real music
% 'synthetic' generated mixture, exact ground trxuth
source = 'stems';

switch source
  case 'stems'
    sd = fullfile(cfg.paths.data, 'stems');
    [d, fs] = audioread(fullfile(sd,'drums.wav'));
    b = audioread(fullfile(sd,'bass.wav'));
    o = audioread(fullfile(sd,'other.wav'));
    d = mean(d,2); 
    b = mean(b,2); 
    o = mean(o,2);

    L = min([numel(d) numel(b) numel(o)]);          % trim to common length
    d = d(1:L); b = b(1:L); o = o(1:L);

    refPer = d;                                     % drums
    refMel = b + o;                                 % everything tonal, no vocals
    mix    = refPer + refMel;

    g = max(abs(mix));                              % one gain; mix = refMel + refPer
    mix = mix/g;  refPer = refPer/g;  refMel = refMel/g;
    name = 'realmix';

  case 'synthetic'
    [mix, refMel, refPer, fs] = makeTestMix(cfg.fs, 8);
    name = 'synthmix';
end

% fprintf('%s: %.2f s at %d Hz\n', name, numel(mix)/fs, fs);
% fprintf('mix = melodic + percussive to %.1e\n', max(abs(mix-(refMel+refPer))));
% fprintf('energy: percussive %.0f%%, melodic %.0f%%\n\n',100*sum(refPer.^2)/sum(mix.^2), 100*sum(refMel.^2)/sum(mix.^2));

% separate
tic;
[estMel, estPer, S, Mh] = separate(mix, fs, cfg);
elapsed = toc;
fprintf('separated %.1f s of audio in %.2f s\n', numel(mix)/fs, elapsed);

% score
baseMel = computeSDR(mix, refMel);     
basePer = computeSDR(mix, refPer);
sdrMel  = computeSDR(estMel, refMel);
sdrPer  = computeSDR(estPer, refPer);

fprintf('%-12s %10s %10s %10s\n', '', 'mixture', 'separated', 'gain');
fprintf('%-12s %9.2f %10.2f %10.2f\n', 'melodic',    baseMel, sdrMel, sdrMel-baseMel);
fprintf('%-12s %9.2f %10.2f %10.2f\n', 'percussive', basePer, sdrPer, sdrPer-basePer);
fprintf('%-12s %9s %10s %10.2f  dB\n\n', 'mean', '', '',((sdrMel-baseMel)+(sdrPer-basePer))/2);

% write audio - 5 files: input, both estimates, both ground truths
audiowrite(fullfile(outDir,[name '_1_mix.wav']),             norm1(mix),    fs);
audiowrite(fullfile(outDir,[name '_2_est_percussive.wav']),  norm1(estPer), fs);
audiowrite(fullfile(outDir,[name '_3_TRUE_percussive.wav']), norm1(refPer), fs);
audiowrite(fullfile(outDir,[name '_4_est_melodic.wav']),     norm1(estMel), fs);
audiowrite(fullfile(outDir,[name '_5_TRUE_melodic.wav']),    norm1(refMel), fs);
fprintf('wrote 5 wavs to %s\n', outDir);

% spectrograms
Xh = myStft(estMel, fs, cfg.winLen, cfg.hop, cfg.winType);
Xp = myStft(estPer, fs, cfg.winLen, cfg.hop, cfg.winType);

f = (0:cfg.winLen/2)' * (fs/cfg.winLen) / 1000;
t = (0:size(S,2)-1) * cfg.hop / fs;

figure('Name','separation','Position',[100 100 1400 380]);
plotSpec(t, f, S,       'Mixture',    1, 1, 3);
plotSpec(t, f, abs(Xh), 'Melodic',    2, 1, 3);
plotSpec(t, f, abs(Xp), 'Percussive', 3, 1, 3);
saveas(gcf, fullfile(figDir, [name '_spectrograms.png']));

% estimate vs ground truth - this is the slide that proves it worked
Rh = myStft(refMel, fs, cfg.winLen, cfg.hop, cfg.winType);
Rp = myStft(refPer, fs, cfg.winLen, cfg.hop, cfg.winType);

figure('Name','estimate vs truth','Position',[100 100 1000 640]);
plotSpec(t, f, abs(Xp), 'Estimated percussive', 1, 2, 2);
plotSpec(t, f, abs(Xh), 'Estimated melodic',    2, 2, 2);
plotSpec(t, f, abs(Rp), 'True percussive',      3, 2, 2);
plotSpec(t, f, abs(Rh), 'True melodic',         4, 2, 2);
saveas(gcf, fullfile(figDir, [name '_vs_truth.png']));

% listen  (uncomment one at a time)
% soundsc(mix,    fs);
% soundsc(estPer, fs);   soundsc(refPer, fs);
% soundsc(estMel, fs);   soundsc(refMel, fs);

function y = norm1(x)
    y = 0.95 * x / max(abs(x));
end

function plotSpec(t, f, M, ttl, k, nr, nc)
    subplot(nr, nc, k);
    imagesc(t, f, 20*log10(M + eps));
    axis xy; ylim([0 5]); caxis([-60 20]);
    xlabel('Time (s)'); ylabel('kHz'); title(ttl); colormap turbo;
end