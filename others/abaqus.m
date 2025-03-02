abaqus_dt = csvread("../two_rods/two_rods_fixed_connection/abaqus_ell_outplane_load.csv");
abaqus_x = abaqus_dt(:,1); 
abaqus_y = abaqus_dt(:,2);

figure
plot(abaqus_x, abaqus_y, '-r')
hold on
plot(Rods(2).U(4*20-1,:), L*1e4, '-b')
legend('ABAQUS', 'DER')