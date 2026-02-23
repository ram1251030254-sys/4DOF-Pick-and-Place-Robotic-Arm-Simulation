function p = params()
    % Define 4-DOF robot parameters (DH parameters style)
    % All lengths in meters
    
    p.L0 = 0.20;   % Base height
    p.L1 = 0.15;  % Link 1 length
    p.L2 = 0.15;  % Link 2 length
    p.L3 = 0.1;   % Link 3 length
    p.L4 = 0.08;  % End effector length
    
    % Joint limits (in degrees)
    p.q1_min = -180; p.q1_max = 180;  % Base rotation
    p.q2_min = -90;  p.q2_max = 90;   % Shoulder
    p.q3_min = -120; p.q3_max = 120;  % Elbow
    p.q4_min = -90;  p.q4_max = 90;   % Wrist
    
    % Gripper parameters
    p.gripper_open = 0.03;   % Open width
    p.gripper_closed = 0.01; % Closed width
end