function draw_joint_3d(position, radius, color)
    % Draw a joint as a sphere at the given position
    if nargin < 2, radius = 0.05; end
    if nargin < 3, color = [0.2 0.2 0.8]; end
    
    [X, Y, Z] = sphere(20);
    X = X * radius + position(1);
    Y = Y * radius + position(2);
    Z = Z * radius + position(3);
    
    surf(X, Y, Z, 'FaceColor', color, 'EdgeColor', 'none', ...
         'FaceLighting', 'gouraud', 'AmbientStrength', 0.5);
end