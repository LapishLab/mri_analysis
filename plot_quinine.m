clear
LAP_eth_t = readtable("LAP_ethanol.csv", Delimiter=",");
LAP_wat_t = readtable("LAP_water.csv", Delimiter=",");
rat_t = readtable("rats.csv", Delimiter=",");

%% convert to arrays
eth = table2array(LAP_eth_t(:,2:end));
wat = table2array(LAP_wat_t(:,2:end));

%% get dates
date_str = LAP_eth_t.Properties.VariableDescriptions(2:end);
dates = datetime(date_str, 'InputFormat','MM/dd');
x = days(dates-dates(1));
%% get groupings
is_F = contains(rat_t.sex, 'F');
is_M = contains(rat_t.sex, 'M');
is_Wis = contains(rat_t.strain, 'Wistar');
is_Had = contains(rat_t.strain, 'HAD1');
is_P = contains(rat_t.strain, 'P');

got_quinine =  rat_t.ratID>30;

%% M vs F - Ethanol & water
figure(1); clf
ymax = 2;

subplot(2,1,1); hold on;
shadedErrorBar(x,eth(is_M & ~got_quinine,:),{@nm,@sem}, 'lineProps', {'.-b'})
shadedErrorBar(x,eth(is_M & got_quinine,:),{@nm,@sem}, 'lineProps', {'.-k'})
title("Male")
ylim([0,ymax])

subplot(2,1,2); hold on;
shadedErrorBar(x,eth(is_F & ~got_quinine,:),{@nm,@sem}, 'lineProps', {'.-r'})
shadedErrorBar(x,eth(is_F & got_quinine,:),{@nm,@sem}, 'lineProps', {'.-k'})
title('Female')
ylim([0,ymax])
ylabel('mg/kg')
xlabel('day')

% 
% subplot(1,2,2); hold on;
% shadedErrorBar(x,wat(is_M,:),{@nm,@sem}, 'lineProps', {'.-b'})
% shadedErrorBar(x,wat(is_F,:),{@nm,@sem}, 'lineProps', {'.-r'})
% title('water')
% ylim([0,ymax])
% ylabel('mg/kg')
% xlabel('day')

legend('no quinine', 'quinine on day 14', Location='south')

exportgraphics(gcf, "sex_quinine.png")
%% Strain - Ethanol & water
figure(2); clf
ymax = 2;

subplot(3,1,1); hold on;
shadedErrorBar(x,eth(is_Wis & ~got_quinine,:),{@nm,@sem}, 'lineProps', {'.-b'})
shadedErrorBar(x,eth(is_Wis & got_quinine,:),{@nm,@sem}, 'lineProps', {'.-k'})
title("Wistar")
ylim([0,ymax])

subplot(3,1,2); hold on;
shadedErrorBar(x,eth(is_P & ~got_quinine,:),{@nm,@sem}, 'lineProps', {'.-r'})
shadedErrorBar(x,eth(is_P & got_quinine,:),{@nm,@sem}, 'lineProps', {'.-k'})
title("P")
ylim([0,ymax])

subplot(3,1,3); hold on;
shadedErrorBar(x,eth(is_Had & ~got_quinine,:),{@nm,@sem}, 'lineProps', {'.-g'})
shadedErrorBar(x,eth(is_Had & got_quinine,:),{@nm,@sem}, 'lineProps', {'.-k'})
title('HAD1')
ylim([0,ymax])

ylabel('mg/kg')
xlabel('day')

% subplot(1,2,2); hold on;
% shadedErrorBar(x,wat(is_Wis,:),{@nm,@sem}, 'lineProps', {'.-b'})
% shadedErrorBar(x,wat(is_P,:),{@nm,@sem}, 'lineProps', {'.-r'})
% shadedErrorBar(x,wat(is_Had,:),{@nm,@sem}, 'lineProps', {'.-g'})
% title('water')
% ylim([0,ymax])
% ylabel('mg/kg')
% xlabel('day')

legend('no quinine', 'quinine on day 14', Location='south')

exportgraphics(gcf, "strain_quinine.png")

%%
function avg = nm(x)
    avg = mean(x, 1, 'omitmissing');
end
function err = sem(x)
    err = std(x,[],1,"omitmissing") ./ sqrt(sum(~isnan(x)));
end