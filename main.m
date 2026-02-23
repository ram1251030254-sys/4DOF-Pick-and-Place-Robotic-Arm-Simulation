%% ============ FINAL PICK & PLACE WITH SINGLE-BOX CONVEYOR ============
clear; clc; close all;

p = params();

%% ================= PARAMETERS =================
box_size = [0.05 0.05 0.04];
gap = 0.005;
base_z = 0;

num_cycles = 10;
q_home = [0 20 10 20];

gripper_offset = [0 0 0.035];

%% Conveyor parameters
conv_y = -0.25;
conv_z = 0.02;
conv_start_x = -0.45;
conv_end_x   = 0.30;
conv_pick_x  = 0.18;
conv_speed   = 0.007;

place_xy = [-0.15 0.20];

%% ================= FIGURE =================
figure('Color','w');
set(gca,'Clipping','off');
axis([-0.5 0.5 -0.5 0.5 0 0.8]);
axis manual; daspect([1 1 1]);
view(45,30); camva(8);
grid on; hold on;
xlabel X; ylabel Y; zlabel Z;

%% ================= STATE VARIABLES =================
stacked_boxes = [];
boxA_x = conv_start_x;

%% ================= MAIN LOOP =================
for k = 1:num_cycles

    %% === MOVE SINGLE BOX TO PICK POINT ===
    while boxA_x < conv_pick_x
        cla; hold on;

        boxA_x = boxA_x + conv_speed;
        if boxA_x > conv_end_x
            boxA_x = conv_start_x;
        end

        draw_conveyor(conv_y,conv_z);
        boxA_x = evalin('base','boxA_x');  % frozen
draw_box([boxA_x conv_y conv_z],box_size,[1 0 0]);
        draw_robot(q_home,p,'open');
        draw_stacked_boxes(stacked_boxes,box_size);

        text(0,0,0.72,sprintf('Pick Count: %d / %d',k,num_cycles), ...
            'FontSize',14,'FontWeight','bold','HorizontalAlignment','center');

        lock_scene;
        pause(0.02);
    end

    pick_pos = [conv_pick_x conv_y conv_z];

    %% === MOVE TO PICK ===
    q1 = inverse_kinematics(pick_pos+[0 0 0.15],p);
    animate(q_home,q1,'open',stacked_boxes,k,num_cycles);

    q2 = inverse_kinematics(pick_pos+[0 0 0.01],p);
    animate(q1,q2,'open',stacked_boxes,k,num_cycles);

    %% === GRIP SYNC (NO TELEPORT) ===
box_pick_pos = [conv_pick_x conv_y conv_z];
% HARD LOCK BOX AT PICK POSITION
boxA_x = conv_pick_x;
assignin('base','boxA_x',boxA_x);
box_attach_transition(q2,q1,box_pick_pos,stacked_boxes,k,num_cycles);


    %% === MOVE TO STACK ===
    place_pos = [place_xy base_z+(k-1)*(box_size(3)+gap)];

    q3 = inverse_kinematics(place_pos+[0 0 0.15],p);
    animate_with_box(q1,q3,stacked_boxes,k,num_cycles);

    q4 = inverse_kinematics(place_pos+[0 0 0.01],p);
    animate_with_box(q3,q4,stacked_boxes,k,num_cycles);

    %% === RELEASE ===
    stacked_boxes = [stacked_boxes; place_pos];

    cla; hold on;
    draw_conveyor(conv_y,conv_z);
    draw_robot(q4,p,'open');
    draw_stacked_boxes(stacked_boxes,box_size);
    lock_scene;
    pause(0.4);

    %% === RETURN HOME ===
    animate(q4,q_home,'open',stacked_boxes,k,num_cycles);

    %% === SPAWN NEXT BOX FOR NEXT LOOP ===
    boxA_x = conv_start_x;
end

disp('✅ SINGLE-BOX CONVEYOR PICK & PLACE COMPLETED');

%% ================= FUNCTIONS =================

function animate(qs,qe,grip,stack,k,n)
p = evalin('base','p');
box_size = evalin('base','box_size');
conv_y = evalin('base','conv_y');
conv_z = evalin('base','conv_z');
boxA_x = evalin('base','boxA_x');
conv_speed = evalin('base','conv_speed');

for i=1:18
    cla; hold on;

    draw_conveyor(conv_y,conv_z);
    draw_box([boxA_x conv_y conv_z],box_size,[1 0 0]);

    q = qs+(qe-qs)*i/30;
    draw_robot(q,p,grip);
    draw_stacked_boxes(stack,box_size);

    text(0,0,0.72,sprintf('Pick Count: %d / %d',k,n), ...
        'FontSize',14,'FontWeight','bold','HorizontalAlignment','center');

    lock_scene; pause(0.02);
end
end

function animate_with_box(qs,qe,stack,k,n)
p = evalin('base','p');
box_size = evalin('base','box_size');
gripper_offset = evalin('base','gripper_offset');
conv_y = evalin('base','conv_y');
conv_z = evalin('base','conv_z');

for i=1:30
    cla; hold on;

    draw_conveyor(conv_y,conv_z);

    q = qs+(qe-qs)*i/30;
    draw_robot(q,p,'closed');

    fk = forward_kinematics(q,p);
    ee = fk(end,:) + gripper_offset;
    draw_box(ee,box_size,[1 0 0]);

    draw_stacked_boxes(stack,box_size);

    text(0,0,0.72,sprintf('Pick Count: %d / %d',k,n), ...
        'FontSize',14,'FontWeight','bold','HorizontalAlignment','center');

    lock_scene; pause(0.02);
end
end

function draw_conveyor(y,z)
[X,Y] = meshgrid(linspace(-0.5,0.5,2),[-0.06 0.06]);
Z = z*ones(size(X));
surf(X,Y+y,Z,'FaceColor',[0.2 0.2 0.2],'EdgeColor','none');
end

function draw_stacked_boxes(boxes,sz)
for i=1:size(boxes,1)
    draw_box(boxes(i,:),sz,[0.2 0.6 1]);
end
end

function lock_scene
axis([-0.5 0.5 -0.5 0.5 0 0.8]);
axis manual; daspect([1 1 1]);
view(45,30); camva(8);
grid on;
light('Position',[1 1 1],'Style','infinite');
light('Position',[-1 -1 1],'Style','infinite');
end

function draw_box(pos,sz,color)
x=pos(1); y=pos(2); z=pos(3);
lx=sz(1)/2; ly=sz(2)/2; lz=sz(3);
V=[x-lx y-ly z;
   x+lx y-ly z;
   x+lx y+ly z;
   x-lx y+ly z;
   x-lx y-ly z+lz;
   x+lx y-ly z+lz;
   x+lx y+ly z+lz;
   x-lx y+ly z+lz];
F=[1 2 3 4;5 6 7 8;1 2 6 5;2 3 7 6;3 4 8 7;4 1 5 8];
patch('Vertices',V,'Faces',F,'FaceColor',color,'EdgeColor','k');
end
function box_attach_transition(qs,qe,box_start,stack,k,n)

p = evalin('base','p');
box_size = evalin('base','box_size');
gripper_offset = evalin('base','gripper_offset');
conv_y = evalin('base','conv_y');
conv_z = evalin('base','conv_z');

steps_approach = 8;   % robot moves, box stays
steps_attach   = 5;   % box locks to gripper

%% ================= PHASE 1: APPROACH =================
for i = 1:steps_approach
    cla; hold on;

    q = qs + (qe-qs)*i/steps_approach;
    draw_robot(q,p,'open');

    draw_conveyor(conv_y,conv_z);
    draw_box(box_start,box_size,[1 0 0]);   % box fixed
    draw_stacked_boxes(stack,box_size);

    text(0,0,0.72,sprintf('Pick Count: %d / %d',k,n), ...
        'FontSize',14,'FontWeight','bold','HorizontalAlignment','center');

    lock_scene;
    pause(0.01);
end

%% ================= PHASE 2: ATTACH =================
for i = 1:steps_attach
    cla; hold on;

    q = qe;                      % robot holds position
    draw_robot(q,p,'closed');

    fk = forward_kinematics(q,p);
    ee = fk(end,:) + gripper_offset;

    alpha = i/steps_attach;      % smooth attach
    box_pos = (1-alpha)*box_start + alpha*ee;

    draw_conveyor(conv_y,conv_z);
    draw_box(box_pos,box_size,[1 0 0]);
    draw_stacked_boxes(stack,box_size);

    text(0,0,0.72,sprintf('Pick Count: %d / %d',k,n), ...
        'FontSize',14,'FontWeight','bold','HorizontalAlignment','center');

    lock_scene;
    pause(0.02);
end

end

    