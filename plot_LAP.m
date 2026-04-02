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

%% M vs F - Ethanol & water
figure(1); clf
ymax = 2;

subplot(1,2,1); hold on;
shadedErrorBar(x,eth(is_M,:),{@nm,@sem}, 'lineProps', {'.-b'})
shadedErrorBar(x,eth(is_F,:),{@nm,@sem}, 'lineProps', {'.-r'})
title('ethanol')
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

legend('M', 'F', Location='north')

exportgraphics(gcf, "sex_LAP.png")
%% Strain - Ethanol & water
figure(2); clf
ymax = 2;

subplot(1,2,1); hold on;
shadedErrorBar(x,eth(is_Wis,:),{@nm,@sem}, 'lineProps', {'.-b'})
shadedErrorBar(x,eth(is_P,:),{@nm,@sem}, 'lineProps', {'.-r'})
shadedErrorBar(x,eth(is_Had,:),{@nm,@sem}, 'lineProps', {'.-g'})
title('ethanol')
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

legend('Wistar', 'P', 'HAD1', Location='north')

exportgraphics(gcf, "strain_LAP.png")

%%
function avg = nm(x)
    avg = mean(x, 1, 'omitmissing');
end
function err = sem(x)
    err = std(x,[],1,"omitmissing") ./ sqrt(sum(~isnan(x)));
end