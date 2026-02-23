function positions = forward_kinematics(q, p)
    % Calculate all joint positions given joint angles
    % q = [q1, q2, q3, q4] in degrees
    % Returns: positions = [p0; p1; p2; p3; p4] where each is [x,y,z]
    
    % Convert to radians
    q = deg2rad(q);
    
    % Base position
    p0 = [0; 0; 0];
    
    % Joint 1 (after base rotation and lift)
    p1 = [0; 0; p.L0];
    
    % Joint 2 (after shoulder rotation)
    p2 = p1 + [p.L1 * cos(q(1)) * cos(q(2));
               p.L1 * sin(q(1)) * cos(q(2));
               p.L1 * sin(q(2))];
    
    % Joint 3 (after elbow rotation)
    p3 = p2 + [p.L2 * cos(q(1)) * cos(q(2) + q(3));
               p.L2 * sin(q(1)) * cos(q(2) + q(3));
               p.L2 * sin(q(2) + q(3))];
    
    % Joint 4 (after wrist rotation)
    p4 = p3 + [p.L3 * cos(q(1)) * cos(q(2) + q(3) + q(4));
               p.L3 * sin(q(1)) * cos(q(2) + q(3) + q(4));
               p.L3 * sin(q(2) + q(3) + q(4))];
    
    % End effector
    p5 = p4 + [p.L4 * cos(q(1)) * cos(q(2) + q(3) + q(4));
               p.L4 * sin(q(1)) * cos(q(2) + q(3) + q(4));
               p.L4 * sin(q(2) + q(3) + q(4))];
    
    positions = [p0'; p1'; p2'; p3'; p4'; p5'];
end