%
% SixLinkPRMScript.
%

close all
%% Drawing the robot
figure;

% The SixLinkRobot function computes layout of all of the links in the
% robot as a function of the 6 configuration space parameters. You can
% adjust these six numbers to see what happens.
start_configuration = [-120 120 -120 120 -120 60];
goal_configuration  = [0 0 0 0 0 180];
fv = SixLinkRobot (start_configuration);

fv2 = SixLinkRobot (goal_configuration);


p = patch (fv);

p.FaceColor = 'red';
p.EdgeColor = 'none';

p2 = patch(fv2);
p2.FaceColor = 'green';
p2.EdgeColor = 'none';

sz = 30;
axis equal;
axis (sz*[-1 1 -1 1]);

%% Add obstacles

obstacle = boxFV(10, 20, 10, 20);
obstacle = appendFV (obstacle, boxFV(-20, 0, -20, -10));
obstacle = appendFV (obstacle, transformFV(boxFV(-10, 10, -10, 10), 30, [-20 20]));

patch (obstacle);

%% Build roadmap

nsamples = 200;
neighbors = 5;

roadmap = PRM (@()(RandomSampleSixLink(obstacle)), @DistSixLink, @(x,y)(LocalPlannerSixLink(x,y,obstacle)), nsamples, neighbors);

%% Add nodes

roadmap2 = AddNode2PRM ([240 120 240 120 240 60]', roadmap, @DistSixLink, @(x,y)(LocalPlannerSixLink(x,y,obstacle)), neighbors);
roadmap2 = AddNode2PRM (goal_configuration', roadmap2, @DistSixLink, @(x,y)(LocalPlannerSixLink(x,y,obstacle)), neighbors);

%% Plan a route

route = ShortestPathDijkstra(roadmap2.edges, roadmap2.edge_lengths, nsamples+1, nsamples+2);

%% Plot the trajectory

filename = 'sixlinkPRM.gif';
gif_fps = 24;
for i = 2:length(route)
    x1 = roadmap2.samples(:,route(i-1));
    x2 = roadmap2.samples(:,route(i));
    
    
    delta = x2 - x1;
    
    t = delta > 180;
    delta(t) = delta(t) - 360;
    
    t = delta < -180;
    delta(t) = delta(t) + 360;
    
    n = ceil(sum(abs(delta)) / 10);
    
    for j = 0:n
        
        x = mod(x1 + (j/n)*delta, 360);
        
        fv = SixLinkRobot (x);
        
        p.Vertices = fv.vertices;
        
        drawnow;
        frame = getframe(gcf);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        
      if i == 2 
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
      else 
          imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',1/gif_fps); 
      end 
        
        if (CollisionCheck(fv, obstacle))
            fprintf (1, 'Ouch\n');
        end
    end
    
end
