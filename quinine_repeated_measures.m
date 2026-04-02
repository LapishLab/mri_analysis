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

%% %% Fig. 11: per group baseline
% b = mean(eth(:,1:10), 2, 'omitmissing');
% 
% edges = 0:.05:2.2;
% 
% figure(11); clf;
% 
% subplot(3,2,1)
% histogram(eth_baseline(is_Wis & is_M),edges)
% xline(thresh_baseline, '--k')
% title("Males")
% ylabel('Wistar (counts)')
% 
% subplot(3,2,2)
% histogram(eth_baseline(is_Wis & is_F),edges)
% xline(thresh_baseline, '--k')
% title("Female")
% % ylabel('Wistar (counts)')
% 
% subplot(3,2,3)
% histogram(eth_baseline(is_P & is_M),edges)
% xline(thresh_baseline, '--k')
% % title("Males")
% ylabel('P (counts)')
% % xlabel('mg/kg')
% 
% subplot(3,2,4)
% histogram(eth_baseline(is_P & is_F),edges)
% xline(thresh_baseline, '--k')
% % title("Female")
% % ylabel('Wistar (counts)')
% % xlabel('mg/kg')
% 
% subplot(3,2,5)
% histogram(eth_baseline(is_Had & is_M),edges)
% xline(thresh_baseline, '--k')
% % title("Males")
% ylabel('HAD1 (counts)')
% xlabel('mg/kg')
% 
% subplot(3,2,6)
% histogram(eth_baseline(is_Had & is_F),edges)
% xline(thresh_baseline, '--k')
% % title("Female")
% % ylabel('Wistar (counts)')
% xlabel('mg/kg')
% %%
% pm = eth_baseline(is_P & is_M);
% pm = pm(pm>1);
% 
% pf = eth_baseline(is_P & is_F);
% pf = pf(pf>1);
% 
% hm = eth_baseline(is_Had & is_M);
% hm = hm(hm>.85 & hm<1.8);
% 
% hf = eth_baseline(is_Had & is_F);
% hf = hf(hf>1 & hf<1.8);
% 
% [
%     mean(pm)
%     mean(pf)
%     mean(hm)
%     mean(hf)
%     ]

%% Extract quinine days
% 64 mg/kg Quinine days
quinine = eth(:, 12:15); %11/11 - 11/14
quinine(Q1_rats, 1) = eth(Q1_rats, 11); % replace Q1 rat values with Monday

% quinine = eth(:, 16:end); %11/17 - 


sensitivity = (1-(quinine./eth_baseline)) *100;

%% Fig. 2. Plot proportion consumed across days (dot plot) 
% rat_group =  true(height(rat_t), 1);
rat_group =  above_baseline;


figure(2); clf; hold on;

subplot(1,3,1) % Wistar
g = is_Wis & rat_group;
scatter_bar(sensitivity(g,:))
ylabel("Quinine Sensitivity: (% reduction from baseline)")
title("Wistar")

subplot(1,3,2) %
g =  is_P & rat_group;
scatter_bar(sensitivity(g,:))
% ylabel("Quinine Sensitivity: (% reduction from baseline)")
title("P")

subplot(1,3,3) %
g =  is_Had & rat_group;
scatter_bar(sensitivity(g,:))
% ylabel("quinine / baseline")
title("HAD")

%% Fig. 3: SEM of estimate for each rat
% rat_group =  above_baseline;% & is_F;

err = std(sensitivity, [], 2, 'omitmissing') ./ sqrt(sum(~isnan(sensitivity), 2));

cats = ["Wistar", "P", "HAD1"];
vals = {
    err(is_Wis & rat_group)
    err(is_P & rat_group)
    err(is_Had & rat_group)
    };

x_cat = categorical(cats, cats);

figure(3); clf; hold on;
bar(x_cat, cellfun(@mean, vals), 'k', FaceAlpha=.1)

for i = 1:length(vals)
    y=vals{i};
    x = i + randn(length(y),1)*.1;
    scatter(x, y, 'filled', MarkerFaceAlpha =.7)
end


ylabel({"Standard Error of quinine sensitivity estimate", "when averaging across days for each rat (%)"})
ylim([0 50])

%%
rat_group =  above_baseline & is_Wis;

rat_t.quinine = mean(quinine,2);
rat_t.baseline = eth_baseline;
rat_t(rat_group,:)
%% Fig 4: Distribution of compulsivity
% rat_group =  above_baseline;% & is_F;
% bins = min(prop(rat_group,:),[], 'all'): .1 :max(prop(rat_group,:),[], 'all');
% bins = [-inf, -50:10:100, inf ];
% bins = -40:10:100;
bins = 0:20:100;


figure(4); clf;
avg = 100* (1-(mean(quinine,2,'omitmissing')./eth_baseline));
% avg = 100* (1-(mean(quinine(:,end),2,'omitmissing')./eth_baseline));

%i love chris. he is so nice.
% kb rulz!!

subplot(3,1,1)
histogram(avg(is_Wis & rat_group), bins)
ylabel("Wistar counts")
xline([0,100], '--k', LineWidth=2)
title("Wistar")

subplot(3,1,2)
histogram(avg(is_P & rat_group), bins)
ylabel("P counts")
xline([0,100], '--k', LineWidth=2)
title("P")

subplot(3,1,3)
histogram(avg(is_Had & rat_group), bins)
ylabel("HAD1 counts")
xline([0,100], '--k', LineWidth=2)
title("HAD1")


xlabel("Quinine Sensitivity: (% reduction from baseline)")
%% functions
function scatter_bar(y)
avg = mean(y, 1, 'omitmissing');
err = std(y, [], 1, 'omitmissing') ./ sqrt(sum(~isnan(y)));
hold on
x = 1:length(avg);
bar(x,avg, 'k', 'FaceAlpha',0.1)
errorbar(x, avg, err,'k',LineStyle="none", LineWidth=2, CapSize=30)
plot(y', '.-','LineWidth',1, 'MarkerSize',20)

xlim([min(x)-.5,max(x)+.5])
yline([0,100],'--k')

ylim([-60,120])
xlabel("Days with quinine")
end
