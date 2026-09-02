function Y = medianFilt2(S, L, dim)
% Median filter S along dimension dim with window length L

if mod(L,2) == 0, L = L + 1; end
if L <= 1, Y = S; return; end

r = (L-1)/2;
[nr, nc] = size(S);
Y = zeros(nr, nc);

maxEl = 2e7;                             
blk   = max(1, floor(maxEl / (nr*L)));

if dim == 2                              % along time (columns)
    idx = [ones(1,r), 1:nc, nc*ones(1,r)];
    Sp  = S(:, idx);
    for j0 = 1:blk:nc
        j1 = min(j0+blk-1, nc);
        m  = j1 - j0 + 1;
        stack = zeros(nr, m, L);
        for k = 1:L
            stack(:,:,k) = Sp(:, j0+k-1 : j0+k-1+m-1);
        end
        Y(:, j0:j1) = median(stack, 3);
    end
else                                     % along frequency (rows)
    idx = [ones(1,r), 1:nr, nr*ones(1,r)];
    Sp  = S(idx, :);
    for j0 = 1:blk:nc
        j1 = min(j0+blk-1, nc);
        stack = zeros(nr, j1-j0+1, L);
        for k = 1:L
            stack(:,:,k) = Sp(k : k+nr-1, j0:j1);
        end
        Y(:, j0:j1) = median(stack, 3);
    end
end

end