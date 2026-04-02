clear
LAP_eth_t = readtable("LAP_ethanol.csv", Delimiter=",");
rat_t = readtable("rats.csv", Delimiter=",");
rat_t.sex = lower(rat_t.sex);
rat_t.strain = lower(rat_t.strain);

% convert to arrays
eth = table2array(LAP_eth_t(:,2:end));

%% get groupings
is_F = contains(rat_t.sex, 'f');
is_M = contains(rat_t.sex, 'm');
is_Wis = contains(rat_t.strain, 'wistar');
is_Had = contains(rat_t.strain, 'had1');
is_P = contains(rat_t.strain, 'p');
Q1_rats =  rat_t.ratID>30;

%% Fig. 1: choose baseline and threshold
eth_baseline = mean(eth(:,1:10), 2, 'omitmissing');

figure(1); clf;
histogram(eth_baseline,25)
xlabel('mg/kg')
ylabel('counts')
title("Baseline ethanol consumption")

thresh_baseline = 0.5;
% scale error of 0.3g for 180g rat: 0.3/(180/1000)*.1578 = 0.26 mg/kg
xline(thresh_baseline, '--k')

above_baseline = eth_baseline>thresh_baseline;

%% Fig. 11: per group baseline
b = mean(eth(:,1:10), 2, 'omitmissing');

edges = 0:.05:2.2;

figure(11); clf;

subplot(3,2,1)
histogram(eth_baseline(is_Wis & is_M),edges)
xline(thresh_baseline, '--k')
title("Males")
ylabel('Wistar (counts)')

subplot(3,2,2)
histogram(eth_baseline(is_Wis & is_F),edges)
xline(thresh_baseline, '--k')
title("Female")
% ylabel('Wistar (counts)')

subplot(3,2,3)
histogram(eth_baseline(is_P & is_M),edges)
xline(thresh_baseline, '--k')
% title("Males")
ylabel('P (counts)')
% xlabel('mg/kg')

subplot(3,2,4)
histogram(eth_baseline(is_P & is_F),edges)
xline(thresh_baseline, '--k')
% title("Female")
% ylabel('Wistar (counts)')
% xlabel('mg/kg')

subplot(3,2,5)
histogram(eth_baseline(is_Had & is_M),edges)
xline(thresh_baseline, '--k')
% title("Males")
ylabel('HAD1 (counts)')
xlabel('mg/kg')

subplot(3,2,6)
histogram(eth_baseline(is_Had & is_F),edges)
xline(thresh_baseline, '--k')
% title("Female")
% ylabel('Wistar (counts)')
xlabel('mg/kg')
%%
pm = eth_baseline(is_P & is_M);
pm = pm(pm>1);

pf = eth_baseline(is_P & is_F);
pf = pf(pf>1);

hm = eth_baseline(is_Had & is_M);
hm = hm(hm>.85 & hm<1.8);

hf = eth_baseline(is_Had & is_F);
hf = hf(hf>1 & hf<1.8);

[
    mean(pm)
    mean(pf)
    mean(hm)
    mean(hf)
    ]
