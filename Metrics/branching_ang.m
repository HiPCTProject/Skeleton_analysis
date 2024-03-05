

%function branch_ang=branching(theta1, theta2, phi1, phi2)

%theta1=theta1*(pi/180);
%theta2=theta2*(pi/180);
%phi1=phi1*(pi/180);
%phi2=phi2*(pi/180);


%branch_ang=real((acos((cos(theta1)*cos(theta2))+(sin(theta1)*sin(theta2)*cos(phi1-phi2))))*(180/pi));


%end

function ang_deg=branching_ang(vec1,vec2)
    dot_prod=dot(vec1,vec2);
    mag=norm(vec1)*norm(vec2);
    ang_rad=acos(dot_prod/mag);
    ang_deg=ang_rad*(180/pi);
end