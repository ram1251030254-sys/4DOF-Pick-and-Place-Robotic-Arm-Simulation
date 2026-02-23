function q = inverse_kinematics(target, p)
    % Simple inverse kinematics for 4-DOF arm
    % target = [x, y, z] desired end effector position
    
    x = target(1);
    y = target(2);
    z = target(3);
    
    % Joint 1: Base rotation
    q1 = atan2(y, x);
    
    % Distance in XY plane
    r = sqrt(x^2 + y^2);
    
    % Height from base
    z_eff = z - p.L0;
    
    % Distance to target (accounting for end effector)
    total_reach = p.L1 + p.L2 + p.L3 + p.L4;
    d = sqrt(r^2 + z_eff^2);
    
    % Check if target is reachable
    if d > total_reach - 0.01
        warning('Target may be out of reach!');
        d = total_reach - 0.01;
    end
    
    % Simplified 3-link planar IK for joints 2, 3, 4
    % Using geometric approach
    
    % Account for end effector and wrist
    d_work = d - p.L4;
    
    % Two-link IK for shoulder and elbow
    L1 = p.L1;
    L2 = p.L2 + p.L3;
    
    cos_q3 = (d_work^2 - L1^2 - L2^2) / (2 * L1 * L2);
    cos_q3 = max(-1, min(1, cos_q3)); % Clamp to valid range
    
    q3 = acos(cos_q3);
    
    alpha = atan2(z_eff, r);
    beta = atan2(L2 * sin(q3), L1 + L2 * cos(q3));
    
    q2 = alpha - beta;
    
    % Joint 4: Keep end effector pointing down
    q4 = -(q2 + q3);
    
    % Convert to degrees
    q = rad2deg([q1, q2, q3, q4]);
    
    % Apply joint limits
    q(1) = max(p.q1_min, min(p.q1_max, q(1)));
    q(2) = max(p.q2_min, min(p.q2_max, q(2)));
    q(3) = max(p.q3_min, min(p.q3_max, q(3)));
    q(4) = max(p.q4_min, min(p.q4_max, q(4)));
end