function draw_object(position, size, color, label)
    % Draw a cubic object at given position
    if nargin < 2, size = 0.03; end
    if nargin < 3, color = [0.8 0.4 0.2]; end
    if nargin < 4, label = ''; end
    
    % Create cube vertices
    vertices = [
        -1 -1 -1; 1 -1 -1; 1 1 -1; -1 1 -1;  % Bottom face
        -1 -1  1; 1 -1  1; 1 1  1; -1 1  1   % Top face
    ] * size/2;
    
    % Translate to position
    vertices(:,1) = vertices(:,1) + position(1);
    vertices(:,2) = vertices(:,2) + position(2);
    vertices(:,3) = vertices(:,3) + position(3);
    
    % Define faces
    faces = [
        1 2 3 4;  % Bottom
        5 6 7 8;  % Top
        1 2 6 5;  % Front
        2 3 7 6;  % Right
        3 4 8 7;  % Back
        4 1 5 8   % Left
    ];
    
    % Draw
    patch('Vertices', vertices, 'Faces', faces, ...
          'FaceColor', color, 'EdgeColor', 'k', 'LineWidth', 1, ...
          'FaceLighting', 'gouraud', 'AmbientStrength', 0.5);
    
    % Add label if provided
    if ~isempty(label)
        text(position(1), position(2), position(3) + size, label, ...
             'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
end