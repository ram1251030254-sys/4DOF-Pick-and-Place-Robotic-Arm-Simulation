function draw_robot(q, p, gripper_state)
    % Draw the complete robot given joint angles
    % gripper_state: 'open' or 'closed'
    
    if nargin < 3
        gripper_state = 'open';
    end
    
    % Get all joint positions
    pos = forward_kinematics(q, p);
    
    % Draw base
    draw_joint_3d(pos(1,:), 0.06, [0.3 0.3 0.3]);
    
    % Draw joints
    draw_joint_3d(pos(2,:), 0.045, [0.8 0.2 0.2]); % Joint 1 - Red
    draw_joint_3d(pos(3,:), 0.04, [0.2 0.8 0.2]);  % Joint 2 - Green
    draw_joint_3d(pos(4,:), 0.035, [0.2 0.2 0.8]); % Joint 3 - Blue
    draw_joint_3d(pos(5,:), 0.03, [0.8 0.8 0.2]);  % Joint 4 - Yellow
    draw_joint_3d(pos(6,:), 0.025, [0.8 0.2 0.8]); % End effector - Magenta
    
    % Draw links
    draw_link_3d(pos(1,:), pos(2,:), 0.025, [0.6 0.6 0.6]); % Base to J1
    draw_link_3d(pos(2,:), pos(3,:), 0.022, [0.6 0.6 0.6]); % Link 1
    draw_link_3d(pos(3,:), pos(4,:), 0.020, [0.6 0.6 0.6]); % Link 2
    draw_link_3d(pos(4,:), pos(5,:), 0.018, [0.6 0.6 0.6]); % Link 3
    draw_link_3d(pos(5,:), pos(6,:), 0.015, [0.6 0.6 0.6]); % End effector
    
    % Draw gripper
    if strcmp(gripper_state, 'open')
        gripper_width = p.gripper_open;
        gripper_color = [0.7 0.7 0.7];
    else
        gripper_width = p.gripper_closed;
        gripper_color = [0.9 0.9 0.2];
    end
    
    % Simple gripper fingers
    end_pos = pos(6,:);
    q_rad = deg2rad(q);
    
    % Direction perpendicular to end effector
    perp_dir = [-sin(q_rad(1)), cos(q_rad(1)), 0];
    
    finger1_end = end_pos + gripper_width * perp_dir;
    finger2_end = end_pos - gripper_width * perp_dir;
    
    draw_link_3d(end_pos, finger1_end, 0.008, gripper_color);
    draw_link_3d(end_pos, finger2_end, 0.008, gripper_color);
end