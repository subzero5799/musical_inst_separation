function cfg = config()
% Parameters for the HPS project. Everything reads from here.

% audio
cfg.fs = 22050;

% STFT
cfg.winLen  = 1024;
cfg.overlap = 0.75;
cfg.hop     = round(cfg.winLen * (1 - cfg.overlap));
cfg.winType = 'hann';

% median filtering (M1)
cfg.Lh_ms = 1000;
cfg.Lp_hz = 1200;

% masking (M1)
cfg.maskType  = 'soft';     % 'binary' | 'soft'
cfg.maskPower = 2;

% paths
root = fileparts(mfilename('fullpath'));
cfg.paths.root    = root;
cfg.paths.src     = fullfile(root, 'src');
cfg.paths.data    = fullfile(root, 'data');
cfg.paths.results = fullfile(root, 'results');

cfg.reconTol = 1e-10;

end