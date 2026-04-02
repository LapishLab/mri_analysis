clear
LAP_eth_t = readtable("LAP_ethanol.csv", Delimiter=",");
rat_t = readtable("rats.csv", Delimiter=",");
rat_t.sex = lower(rat_t.sex);
rat_t.strain = lower(rat_t.strain);

% convert to arrays
eth = table2array(LAP_eth_t(:,2:end));

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

%% pull out ethanol only vs quinine 
eth_Q = eth(:,end);
eth_Q(Q1_rats) = eth(Q1_rats,end-1);

eth_O = eth(:,end-1);
eth_O(Q1_rats) = eth(Q1_rats,end);

q_last = [eth(:,1:end-2), eth_O, eth_Q];
%% histograms per group
% rat_group =  true(height(rat_t), 1);
% rat_group = is_Wis %& is_M;
rat_group = is_Wis % & ~Q1_rats;
% rat_group = is_P & ~Q1_rats;

figure(2); clf; hold on;

% bin_edges = [-inf, -.1:.1:2, inf];
r2 = max(max(q_last(rat_group, end-2:end)));
r1 = min([0, min(min(q_last(rat_group, end-2:end)))]);
bin_edges = r1:.1:r2;

% subplot(3,1,1);
% histogram(eth(rat_group, end-2),bin_edges)
% ylabel("count")
% title('alcohol (last Fri)')
% 
subplot(3,1,1);
avg = mean(eth(:,1:10), 2, 'omitmissing');
histogram(avg(rat_group),bin_edges)
ylabel("count")
title('alcohol (avg baseline)')

% subplot(3,1,1);
% histogram(eth(rat_group,1:10),bin_edges)
% ylabel("count")
% title('alcohol (all baseline)')

subplot(3,1,2);
histogram(eth_O(rat_group),bin_edges)
ylabel("count")
title('alcohol (counterbalanced)')

subplot(3,1,3);
histogram(eth_Q(rat_group),bin_edges)
ylabel("count")
title('quinine (counterbalanced)')

xlabel('mg/kg')

%% dot plot 
% rat_group1 =  true(height(rat_t), 1);
% rat_group =  is_Wis;
rat_group =  is_P;

cut_to = 10;

figure(3); clf; hold on;
plot(x(end-cut_to:end), q_last(rat_group, end-cut_to:end), '.-')

%% dot plot  subgroup comparison
split_by = Q1_rats;
rat_group1 = rat_group & split_by;
rat_group2 = rat_group & ~split_by;

figure(3); clf; hold on;
plot(x(end-cut_to:end), q_last(rat_group1, end-cut_to:end), '.-b')
plot(x(end-cut_to:end), q_last(rat_group2, end-cut_to:end), '.-r')
%%
function scatter_bar(x, y)
x = x + randn(length(y), 1) * .1;
scatter(x, y)


end