function draw_link_3d(point1, point2, radius, color)
    % Draw a link as a cylinder between two points
    if nargin < 3, radius = 0.03; end
    if nargin < 4, color = [0.7 0.7 0.7]; end
    
    vec = point2 - point1;
    length = norm(vec);
    
    if length < 0.001
        return; % Skip if points are too close
    end
    
    [X, Y, Z] = cylinder(radius, 20);
    Z = Z * length;
    
    % Calculate rotation angles
    vec_norm = vec / length;
    z_axis = [0; 0; 1];
    
    if abs(dot(vec_norm, z_axis)) < 0.999
        rot_axis = cross(z_axis, vec_norm);
        rot_axis = rot_axis / norm(rot_axis);
        rot_angle = acos(dot(z_axis, vec_norm));
        
        % Rodrigues rotation formula
        K = [0 -rot_axis(3) rot_axis(2); 
             rot_axis(3) 0 -rot_axis(1); 
             -rot_axis(2) rot_axis(1) 0];
        R = eye(3) + sin(rot_angle)*K + (1-cos(rot_angle))*K*K;
    else
        if vec_norm(3) < 0
            R = [-1 0 0; 0 -1 0; 0 0 -1];
        else
            R = eye(3);
        end
    end
    
    % Apply rotation and translation
    for i = 1:size(X, 1)
        for j = 1:size(X, 2)
            point = [X(i,j); Y(i,j); Z(i,j)];
            rotated = R * point;
            X(i,j) = rotated(1) + point1(1);
            Y(i,j) = rotated(2) + point1(2);
            Z(i,j) = rotated(3) + point1(3);
        end
    end
    
    surf(X, Y, Z, 'FaceColor', color, 'EdgeColor', 'none', ...
         'FaceLighting', 'gouraud', 'AmbientStrength', 0.5);
end