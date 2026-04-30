function plotGeometry(points, tV, plotColor)

A = points(1,:);
B = points(2,:);
C = points(3,:);
D = points(4,:);
% 
% A = [traj(1,tV,1),traj(2,tV,1)];
% B = [traj(1,tV,2),traj(2,tV,2)];
% C = [traj(1,tV,3),traj(2,tV,3)];
% D = [traj(1,tV,4),traj(2,tV,4)];



plot(A(1), A(2),'ro', 'markersize', 14, 'linewidth', 2);
hold on
plot(B(1), B(2), 'rd', 'markersize', 14,'MarkerFaceColor','r');
plot(C(1), C(2),'go', 'markersize', 14, 'linewidth', 2);
plot(D(1), D(2),'gd', 'markersize', 14,'MarkerFaceColor','g');


% RL&RR
line([A(1), C(1)], [A(2), C(2)] ,'color', 'k')
% GL&GR
line([B(1), D(1)], [B(2), D(2)] ,'color', 'k')

% line([A(1), D(1)], [A(2), D(2)] ,'color', 'k')
% % RR&GL
% line([B(1), C(1)], [B(2), C(2)] ,'color', 'k')
% 
% % RL&RR
% line([A(1), B(1)], [A(2), B(2)] ,'color', 'k')
% % GL&GR
% line([C(1), D(1)], [C(2), D(2)] ,'color', 'k')
% 


% Combine the X and Y coordinates
x = [A(1), B(1), C(1), D(1)];
y = [A(2), B(2), C(2), D(2)];

% points = [A;B;C;D];
% Compute centroid
centroid = mean(points, 1);

% Compute angles and sort (CCW order)
[~, idx] = sort(atan2(points(:,2) - centroid(2), points(:,1) - centroid(1)));
sortedPoints = points(idx, :);

% Plot
patch(sortedPoints(:,1), sortedPoints(:,2), plotColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none');



end

