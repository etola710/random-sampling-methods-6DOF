function flag = triangle_intersection(P1, P2)
% triangle_test : returns true if the triangles overlap and false otherwise

%%% All of your code should be between the two lines of stars.
% *******************************************************************
vert2edge = @(V) [V(1,:) - V(2,:);
    V(2,:) - V(3,:);
    V(3,:) - V(1,:)];
%edge to normal function
perp = @(x) [x(2), -x(1)];
%normals
E = [vert2edge(P1);
    vert2edge(P2)];
N=[];
for i = 1:size(E,1)
    N(i,:) = perp(E(i,:));
end
%lambda vectors
L1_d=[];
L2_d=[];
for i = 1:size(N,1)
    for j = 1:size(P1,1)
        L1_d(j) = dot(N(i,:),P1(j,:));
        L2_d(j) = dot(N(i,:),P2(j,:));
    end
    
    if min(L1_d) > max(L2_d) || max(L1_d) < min(L2_d)
        flag = false;
        break;
    else
        flag = true;
    end
end
% *******************************************************************
end