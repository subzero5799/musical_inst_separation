function sdr = computeSDR(est, ref)
% scale invariant signal to distortion ratio, dB

est = est(:);
ref = ref(:);
n   = min(numel(est), numel(ref));
est = est(1:n);
ref = ref(1:n);

est = est - mean(est);
ref = ref - mean(ref);

alpha   = (est' * ref) / (ref' * ref + eps);
target  = alpha * ref;
noise   = est - target;

sdr = 10 * log10( (target'*target) / (noise'*noise + eps) + eps );

end