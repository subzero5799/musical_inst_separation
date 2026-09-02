% runSweep.m, the engineering design study

clear; clc; close all;

here = fileparts(fileparts(mfilename('fullpath')));
addpath(here, fullfile(here,'src'), fullfile(here,'eval'));
cfg = config();

resDir = fullfile(cfg.paths.results,'tables');
figDir = fullfile(cfg.paths.results,'figures');
if ~exist(resDir,'dir'), mkdir(resDir); end
if ~exist(figDir,'dir'), mkdir(figDir); end

source = 'stems';        % 'stems' or 'synthetic'

switch source
  case 'stems'
    sd = fullfile(cfg.paths.data,'stems');
    [d, fs] = audioread(fullfile(sd,'drums.wav'));
    b = audioread(fullfile(sd,'bass.wav'));
    o = audioread(fullfile(sd,'other.wav'));
    d = mean(d,2); b = mean(b,2); o = mean(o,2);
    L = min([numel(d) numel(b) numel(o)]);
    refPer = d(1:L); refMel = b(1:L) + o(1:L);
    mix = refPer + refMel;
    g = max(abs(mix)); mix = mix/g; refPer = refPer/g; refMel = refMel/g;
  case 'synthetic'
    [mix, refMel, refPer, fs] = makeTestMix(cfg.fs, 8);
end

base = [computeSDR(mix,refMel), computeSDR(mix,refPer)];
fprintf('source: %s   baseline: mel %.2f dB, per %.2f dB\n\n', source, base);

% grid
winLens  = [1024 2048];
LhList   = [100 200 400 600 800 1000 1200 1600 2000];   % ms
LpList   = [500 1200];                                  % Hz 
maskList = {'binary','soft'};

rows = {};
fprintf('%-8s %7s %7s %7s %8s %8s %8s %8s\n', ...
        'mask','winLen','Lh_ms','Lp_Hz','SDRmel','SDRper','gain','time_s');
fprintf('%s\n', repmat('-',1,72));

for mi = 1:numel(maskList)
  for wi = 1:numel(winLens)
    for hi = 1:numel(LhList)
      for pi = 1:numel(LpList)

        c = cfg;
        c.maskType = maskList{mi};
        c.winLen   = winLens(wi);
        c.hop      = round(c.winLen * (1 - c.overlap));
        c.Lh_ms    = LhList(hi);
        c.Lp_hz    = LpList(pi);

        tic; [em, ep] = separate(mix, fs, c); el = toc;

        sm = computeSDR(em, refMel);
        sp = computeSDR(ep, refPer);
        gain = ((sm-base(1)) + (sp-base(2)))/2;

        rows(end+1,:) = {c.maskType, c.winLen, c.Lh_ms, c.Lp_hz, sm, sp, gain, el}; 
        fprintf('%-8s %7d %7d %7d %8.2f %8.2f %8.2f %8.2f\n', c.maskType, c.winLen, c.Lh_ms, c.Lp_hz, sm, sp, gain, el);
      end
    end
  end
end

T = cell2table(rows,'VariableNames',{'mask','winLen','Lh_ms','Lp_Hz','SDR_melodic','SDR_percussive','gain_dB','time_s'});
writetable(T, fullfile(resDir, ['sweep_' source '.csv']));

[~, bi] = max(T.gain_dB);
fprintf('\nbest: %s winLen=%d Lh=%d ms Lp=%d Hz -> %.2f dB gain, %.2f s\n',T.mask{bi}, T.winLen(bi), T.Lh_ms(bi), T.Lp_Hz(bi), T.gain_dB(bi), T.time_s(bi));

% figure 1: quality vs filter length
figure('Name','SDR vs filter length','Position',[100 100 700 460]);
hold on; grid on;
cols = [0 0.45 0.74; 0.85 0.33 0.10];
for wi = 1:numel(winLens)
    m = strcmp(T.mask,'soft') & T.winLen==winLens(wi) & T.Lp_Hz==1200;
    plot(T.Lh_ms(m), T.gain_dB(m), '-o', 'Color', cols(wi,:), 'LineWidth', 1.8,'MarkerFaceColor', cols(wi,:), 'MarkerSize', 6,'DisplayName', sprintf('winLen %d', winLens(wi)));
end

% mark the peak of the winLen 1024 curve
m1 = strcmp(T.mask,'soft') & T.winLen==1024 & T.Lp_Hz==1200;
[pk, pj] = max(T.gain_dB(m1));
lh1 = T.Lh_ms(m1);
plot(lh1(pj), pk, 'p', 'MarkerSize', 20, 'MarkerFaceColor', [0.95 0.75 0.1],'MarkerEdgeColor','k', 'DisplayName', sprintf('peak: %d ms', lh1(pj)));
text(lh1(pj), pk, sprintf('  optimum %d ms', lh1(pj)), 'FontSize', 11,'VerticalAlignment','bottom');

xlabel('Harmonic filter length L_h (ms)');
ylabel('Mean SDR gain over mixture (dB)');
title(sprintf('Separation quality vs filter length (%s)', source));
legend('Location','southwest');
saveas(gcf, fullfile(figDir, ['sdr_vs_Lh_' source '.png']));

% figure 2: quality vs runtime
figure('Name','quality vs cost','Position',[100 100 700 460]);
hold on; grid on;
for mi = 1:numel(maskList)
    m = strcmp(T.mask, maskList{mi});
    scatter(T.time_s(m), T.gain_dB(m), 42, 'filled', 'DisplayName', maskList{mi});
end
xlabel('Runtime (s)'); ylabel('Mean SDR gain (dB)');
title(sprintf('Quality vs computation (%s)', source));
legend('Location','southeast');
saveas(gcf, fullfile(figDir, ['quality_vs_cost_' source '.png']));

fprintf('saved sweep_%s.csv and 2 figures\n', source);