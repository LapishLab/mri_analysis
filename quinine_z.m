clear
LAP_eth_t = readtable("LAP_ethanol.csv", Delimiter=",");
rat_t = readtable("rats.csv", Delimiter=",");
rat_t.sex = lower(rat_t.sex);
rat_t.strain = lower(rat_t.strain);

% convert to arrays
eth = table2array(LAP_eth_t(:,2:end));

 y_lim = [-0 2];
y_label = "mg/kg";
yline_val = 0;

%% zscore by first 2 weeks of LAP
% avg = mean(eth(:,1:10), 2, 'omitmissing');
% err = std(eth(:,1:10), [], 2, 'omitmissing');
% eth = (eth-avg) ./ err;
% 
% y_label = "std from baseline (day 1-10)";
% y_lim = [-3 1.5];
% yline_val = 0;

%% Use proportion of baseline (first 2 weeks of LAP)
% eth = eth - min(eth(:));
% avg = mean(eth(:,1:10), 2, 'omitmissing');
% eth = eth ./ avg;
% 
% y_label = "Proportion of baseline (day 1-10)";
% y_lim = [0 1.8];
% yline_val = 1;

%% get dates
date_str = LAP_eth_t.Properties.VariableDescriptions(2:end);
dates = datetime(date_str, 'InputFormat','MM/dd');
x = days(dates-dates(1));

%% get groupings
is_F = contains(rat_t.sex, 'f');
is_M = contains(rat_t.sex, 'm');
is_Wis = contains(rat_t.strain, 'wistar');
is_Had = contains(rat_t.strain, 'had1');
is_P = contains(rat_t.strain, 'p');

Q1_rats =  rat_t.ratID>30;

%% Figure 1:  M vs F
figure(1); clf


subplot(2,1,1); hold on;
shadedErrorBar(x,eth(is_M & ~Q1_rats,:),{@nm,@sem}, 'lineProps', {'.-b'})
shadedErrorBar(x,eth(is_M & Q1_rats,:),{@nm,@sem}, 'lineProps', {'.-r'})
title("Male")
ylim(y_lim)
ylabel(y_label)
yline(yline_val,'--k')

legend('Q day 15', 'Q day 14', Location='south')

subplot(2,1,2); hold on;
shadedErrorBar(x,eth(is_F & ~Q1_rats,:),{@nm,@sem}, 'lineProps', {'.-b'})
shadedErrorBar(x,eth(is_F & Q1_rats,:),{@nm,@sem}, 'lineProps', {'.-r'})
title('Female')
ylim(y_lim)
ylabel(y_label)
xlabel('day')
yline(yline_val,'--k')





%% Figure 2:  Strain
figure(2); clf

subplot(3,1,1); hold on;
shadedErrorBar(x,eth(is_Wis & ~Q1_rats,:),{@nm,@sem}, 'lineProps', {'.-b'})
shadedErrorBar(x,eth(is_Wis & Q1_rats,:),{@nm,@sem}, 'lineProps', {'.-r'})
title("Wistar")
ylim(y_lim)
ylabel(y_label)
yline(yline_val,'--k')

legend('Q day 15', 'Q day 14', Location='south')

subplot(3,1,2); hold on;
shadedErrorBar(x,eth(is_P & ~Q1_rats,:),{@nm,@sem}, 'lineProps', {'.-b'})
shadedErrorBar(x,eth(is_P & Q1_rats,:),{@nm,@sem}, 'lineProps', {'.-r'})
title("P")
ylim(y_lim)
ylabel(y_label)
yline(yline_val,'--k')

subplot(3,1,3); hold on;
shadedErrorBar(x,eth(is_Had & ~Q1_rats,:),{@nm,@sem}, 'lineProps', {'.-b'})
shadedErrorBar(x,eth(is_Had & Q1_rats,:),{@nm,@sem}, 'lineProps', {'.-r'})
title('HAD1')
ylim(y_lim)
ylabel(y_label)
yline(yline_val,'--k')

xlabel('day')

%% Figure 3: Sex + Strain
figure(3); clf

% sex = is_M;
sex = is_F;

subplot(3,1,1); hold on;
shadedErrorBar(x,eth(is_Wis & ~Q1_rats & sex,:),{@nm,@sem}, 'lineProps', {'.-b'})
shadedErrorBar(x,eth(is_Wis & Q1_rats & sex,:),{@nm,@sem}, 'lineProps', {'.-r'})
title("Wistar")
ylim(y_lim)
ylabel(y_label)
yline(yline_val,'--k')

legend('Q day 15', 'Q day 14', Location='south')

subplot(3,1,2); hold on;
shadedErrorBar(x,eth(is_P & ~Q1_rats & sex,:),{@nm,@sem}, 'lineProps', {'.-b'})
shadedErrorBar(x,eth(is_P & Q1_rats & sex,:),{@nm,@sem}, 'lineProps', {'.-r'})
title("P")
ylim(y_lim)
ylabel(y_label)
yline(yline_val,'--k')

subplot(3,1,3); hold on;
shadedErrorBar(x,eth(is_Had & ~Q1_rats & sex,:),{@nm,@sem}, 'lineProps', {'.-b'})
shadedErrorBar(x,eth(is_Had & Q1_rats & sex,:),{@nm,@sem}, 'lineProps', {'.-r'})
title('HAD1')
ylim(y_lim)
ylabel(y_label)
yline(yline_val,'--k')

xlabel('day')

%%
function avg = nm(x)
    avg = mean(x, 1, 'omitmissing');
end
function err = sem(x)
    err = std(x,[],1,"omitmissing") ./ sqrt(sum(~isnan(x)));
end