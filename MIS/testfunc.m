% Problem Set 17.1, #15
% Region: |z - 1/2| <= 1/2   (disk of radius 1/2 centered at 1/2, passes through z=0)
% Mapping: w = 1/z
% The disk boundary passes through the origin, so its image is a
% straight line (not a circle) -> the image region is a half-plane.

% Create a new figure
figure('Position', [100, 100, 800, 400]);
sgtitle('Complex Mapping: w = 1/z'); % Overall title

% ==========================================
% Plot 1: z-plane
% ==========================================
subplot(1, 2, 1);
hold on; grid on; axis equal;

% Disk: center 1/2, radius 1/2
cx = 0.5; cy = 0; rz = 0.5;
theta_z = linspace(0, 2*pi, 200);
x_circ_z = cx + rz*cos(theta_z);
y_circ_z = cy + rz*sin(theta_z);

% Fill region
fill(x_circ_z, y_circ_z, 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
% Plot boundary (solid, since it's a full closed circle)
plot(x_circ_z, y_circ_z, 'b-', 'LineWidth', 2);

% Mark key points: origin (on boundary), center, and z = 1 (on boundary)
plot(0, 0, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 5);
text(0.02, -0.08, 'z = 0', 'FontSize', 9);
plot(1, 0, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 5);
text(0.85, -0.08, 'z = 1', 'FontSize', 9);
plot(0.5, 0, 'k+', 'MarkerSize', 7, 'LineWidth', 1.2);
text(0.52, 0.08, 'z = 1/2', 'FontSize', 9);

% Formatting
title('z-plane: |z - 1/2| \leq 1/2');
xlabel('Re(z)');
ylabel('Im(z)');
xlim([-0.3, 1.3]);
ylim([-0.8, 0.8]);

% ==========================================
% Plot 2: w-plane (w = 1/z)
% ==========================================
subplot(1, 2, 2);
hold on; grid on; axis equal;

% Image is the half-plane Re(w) >= 1 (boundary through origin maps to
% the line u = 1; the disk interior maps to the right of that line;
% z = 0 itself maps to w = infinity).
u_min = 1; u_max = 3.2;
v_min = -1.4; v_max = 1.4;

% Fill half-plane region (clipped to the plot window)
fill([u_min, u_max, u_max, u_min], [v_min, v_min, v_max, v_max], ...
     'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
% Plot boundary line (solid, extends to infinity in both directions)
plot([u_min, u_min], [v_min, v_max], 'r-', 'LineWidth', 2);

% Mark image points: z=1/2 -> w=2,  z=1 -> w=1,  z=0 -> w=infinity
plot(2, 0, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 5);
text(2.05, -0.15, 'w = 2', 'FontSize', 9);
plot(1, 0, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 5);
text(0.7, -0.25, 'w = 1', 'FontSize', 9);
annotation('textarrow', [0.85 0.91], [0.5 0.5], 'String', 'w \to \infty', 'FontSize', 9);

% Formatting
title('w-plane: Re(w) \geq 1');
xlabel('Re(w)');
ylabel('Im(w)');
xlim([u_min - 0.3, u_max]);
ylim([v_min, v_max]);