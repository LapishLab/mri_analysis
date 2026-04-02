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

%% choose basline and calculate proportion
% eth_baseline = eth_O;
eth_baseline = mean(eth(:,1:10), 2, 'omitmissing');

eth_baseline = eth_baseline - min(eth_Q);
eth_Q = eth_Q - min(eth_Q);


eth_prop = eth_Q ./ eth_baseline;
% histogram(eth_prop)
%% calculate eth

cats = ["Wistar", "P", "HAD1"];

vals = [eth_prop(is_Wis), eth_prop(is_P), eth_prop(is_Had)];

x_cat = categorical(cats, cats);
x_num = (1:length(cats)) + randn(size(vals,1), 1)*.1;

figure(1); clf; hold on;
bar(x_cat, mean(vals))
scatter(x_num, vals)

ylabel("eth quinine/baseline")