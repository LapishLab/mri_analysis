% Load all data from excel
[water, ethanol, weight, day_info, rat_info] = load_excel_data();

% Make all negative consumption values = 0
ethanol(ethanol<0) = 0;
water(water<0) = 0;

% Add "day" column with day 0 being the first day of IAP
day_info.day = days(day_info.date - day_info.date(1));

%% Drop the day where no ethanol values were obtained
good_days = ~all(isnan(ethanol));
water = water(:,good_days);
ethanol = ethanol(:,good_days);
weight = weight(:, good_days);
day_info = day_info(good_days,:);

%% Merge 2 days with counterbalanced quinine (discard no-quinine rat data) 

first_quinine_1_30 = find(day_info.quinine_r1_30>0, 1);
first_quinine_31_60 = find(day_info.quinine_r31_60>0, 1);

water(31:60, first_quinine_1_30) = water(31:60, first_quinine_31_60);
water(:,first_quinine_31_60) = [];

ethanol(31:60, first_quinine_1_30) = ethanol(31:60, first_quinine_31_60);
ethanol(:,first_quinine_31_60) = [];

weight(31:60, first_quinine_1_30) = weight(31:60, first_quinine_31_60);
weight(:,first_quinine_31_60) = [];

% Simplify day info to only keep 2nd day of counterbalance
day_info(first_quinine_31_60,:) = [];
day_info = renamevars(day_info, "quinine_r1_30", "quinine");
day_info = removevars(day_info, "quinine_r31_60");

%% Calculate metrics of interest
preference = ethanol ./ (ethanol+water);
E_per_kg = 0.1578 * ethanol ./ weight * 1000;
W_per_kg = 0.1578 * water ./ weight * 1000;
E_per_kg_per_hr = E_per_kg ./ day_info.duration';

%% Prepare logical indices and colors for splitting rats
% Male vs. Female
is_male = strcmpi(rat_info.sex, "M");
m_color = [0 0 1];
f_color = [1 0 0];

% Wistar vs. P vs. Had1
is_wis = strcmpi(rat_info.strain, "WISTAR");
is_p = strcmpi(rat_info.strain, "P");
is_had = strcmpi(rat_info.strain, "HAD1");

w_color = [0 1 1];
p_color = [1 0 1];
h_color = [44, 219, 22] / 255;

%% Prepare functions for plotting
sem = @(y) std(y, 'omitmissing') ./ sqrt(sum(~isnan(y)));
nan_mean = @(y) mean(y, "omitmissing");

%% %%%%%%%%%% Figure 1: Ethanol intake progression throughout IAP %%%%% 

% X-axis is all IAP days
is_IAP = day_info.duration==1440;
x = day_info.day(is_IAP);


% Plotting Intake
y_lab = 'Ethanol intake (mg/kg)';
y = E_per_kg(:, is_IAP);
y_lim = [0 10];

figure(1); clf;
% male vs female
subplot(2,1,1); hold on
shadedErrorBar(x, y(is_male,:), {nan_mean, sem}, 'lineProps', {'Color',m_color, 'DisplayName', 'Male'})
shadedErrorBar(x, y(~is_male,:), {nan_mean, sem}, 'lineProps', {'Color',f_color, 'DisplayName', 'Female'})
% legend()
xlabel('Days')
ylabel(y_lab)
ylim(y_lim)
xlim([0 80])
% Wistar vs P vs HAD1
subplot(2,1,2); hold on
shadedErrorBar(x, y(is_p,:), {nan_mean, sem}, 'lineProps', {'Color',p_color, 'DisplayName', 'P'})
shadedErrorBar(x, y(is_wis,:), {nan_mean, sem}, 'lineProps', {'Color',w_color, 'DisplayName', 'Wistar'})
shadedErrorBar(x, y(is_had,:), {nan_mean, sem}, 'lineProps', {'Color',h_color, 'DisplayName', 'HAD1'})
% legend()
xlabel('Days')
ylabel(y_lab)
ylim(y_lim)
xlim([0 80])
saveas(gcf, 'fig1.svg')




% Plotting prefrence
y_lab = 'Ethanol preference';
y = preference(:, is_IAP);
y_lim = [0 1];

figure(11); clf;
% male vs female
subplot(2,1,1); hold on
shadedErrorBar(x, y(is_male,:), {nan_mean, sem}, 'lineProps', {'Color',m_color, 'DisplayName', 'Male'})
shadedErrorBar(x, y(~is_male,:), {nan_mean, sem}, 'lineProps', {'Color',f_color, 'DisplayName', 'Female'})
% legend()
xlabel('Days')
ylabel(y_lab)
ylim(y_lim)
xlim([0 80])
% Wistar vs P vs HAD1
subplot(2,1,2); hold on
shadedErrorBar(x, y(is_p,:), {nan_mean, sem}, 'lineProps', {'Color',p_color, 'DisplayName', 'P'})
shadedErrorBar(x, y(is_wis,:), {nan_mean, sem}, 'lineProps', {'Color',w_color, 'DisplayName', 'Wistar'})
shadedErrorBar(x, y(is_had,:), {nan_mean, sem}, 'lineProps', {'Color',h_color, 'DisplayName', 'HAD1'})
% legend()
xlabel('Days')
ylabel(y_lab)
ylim(y_lim)
xlim([0 80])
saveas(gcf, 'fig11.svg')
%% %%%% Figure 2: Transition from IAP->LAP and reaction to reduced time %%%%%

% X-axis is last IAP day and LAP days without quinine
is_transition = day_info.duration==20 & day_info.quinine==0;
is_transition(find(is_IAP, 6, 'last')) = true; % Also add last 1 day of IAP

x = day_info.day(is_transition);
% x = x - x(2)


% Plotting intake
y_lab = 'Ethanol intake (mg/kg)';
y = E_per_kg(:, is_transition);
y_lim = [0 10];


figure(2); clf;
% male vs female
subplot(2,1,1); hold on
shadedErrorBar(x, y(is_male,:), {nan_mean, sem}, 'lineProps', {'Color',m_color, 'DisplayName', 'Male'})
shadedErrorBar(x, y(~is_male,:), {nan_mean, sem}, 'lineProps', {'Color',f_color, 'DisplayName', 'Female'})
% legend()
xlabel('Days')
ylabel(y_lab)
ylim(y_lim)
xline (82, '--k')
% Wistar vs P vs HAD1
subplot(2,1,2); hold on
shadedErrorBar(x, y(is_p,:), {nan_mean, sem}, 'lineProps', {'Color',p_color, 'DisplayName', 'P'})
shadedErrorBar(x, y(is_wis,:), {nan_mean, sem}, 'lineProps', {'Color',w_color, 'DisplayName', 'Wistar'})
shadedErrorBar(x, y(is_had,:), {nan_mean, sem}, 'lineProps', {'Color',h_color, 'DisplayName', 'HAD1'})
% legend()
xlabel('Days')
ylabel(y_lab)
ylim(y_lim)
xline (82, '--k')

saveas(gcf, 'fig2.svg')

% Plotting preference
y_lab = 'Ethanol preference';
y = preference(:, is_transition);
y_lim = [0 1];

figure(22); clf;
% male vs female
subplot(2,1,1); hold on
shadedErrorBar(x, y(is_male,:), {nan_mean, sem}, 'lineProps', {'Color',m_color, 'DisplayName', 'Male'})
shadedErrorBar(x, y(~is_male,:), {nan_mean, sem}, 'lineProps', {'Color',f_color, 'DisplayName', 'Female'})
% legend()
xlabel('Days')
ylabel(y_lab)
ylim(y_lim)
xline (82, '--k')

% Wistar vs P vs HAD1
subplot(2,1,2); hold on
shadedErrorBar(x, y(is_p,:), {nan_mean, sem}, 'lineProps', {'Color',p_color, 'DisplayName', 'P'})
shadedErrorBar(x, y(is_wis,:), {nan_mean, sem}, 'lineProps', {'Color',w_color, 'DisplayName', 'Wistar'})
shadedErrorBar(x, y(is_had,:), {nan_mean, sem}, 'lineProps', {'Color',h_color, 'DisplayName', 'HAD1'})
% legend()
xlabel('Days')
ylabel(y_lab)
ylim(y_lim)
xline (82, '--k')

saveas(gcf, 'fig22.svg')
%% %%%%%%%%%% Figure 3: Quinine Sensitivity (compulsivity) %%%%%%%%%%%%%

% X-groups are baseline (last 4 days of regular LAP), low-quinine, and high-quinine

is_baseline = day_info.duration==20 & day_info.quinine==0;
is_low_quinine = day_info.duration==20 & day_info.quinine==185;
is_high_quinine = day_info.duration==20 & day_info.quinine==740;


% y-axis = ethanol intake (quinine (mg/kg) / baseline (mg/kg)) (averaged
% per condition (accross days)
baseline = mean(E_per_kg(:, is_baseline), 2, "omitmissing");
low_quinine = mean(E_per_kg(:, is_low_quinine), 2, "omitmissing");
low_quinine = (low_quinine ./ baseline) * 100;

high_quinine = mean(E_per_kg(:, is_high_quinine), 2, "omitmissing");
high_quinine = (high_quinine ./ baseline) * 100;

y_lab = 'Consumption (%)';


figure(5);clf
histogram(baseline,20)
xlabel("Ethanol consumption (mg/kg)")
ylabel('counts')
title("baseline")

sufficient_baseline = baseline>.5;
%% Plotting Low Qhinine
figure(3); clf;
sgtitle("Low-quinine")
y = low_quinine;
y_lim = [0 150];

% male vs female
subplot(2,1,1); hold on
x = ["Male", "Female"];
y_cell = {y(is_male&sufficient_baseline), y(~is_male&sufficient_baseline)};
raw_data_error_bar(x, y_cell, bar_funcs={nan_mean, sem},bar_color={m_color, f_color})
ylabel(y_lab)
ylim(y_lim)
yline(100, '--k')

% Wistar vs P vs HAD1
subplot(2,1,2); hold on
x = ["Wistar", "P", "HAD1"];
y_cell = {y(is_wis&sufficient_baseline), y(is_p&sufficient_baseline), y(is_had&sufficient_baseline)};
raw_data_error_bar(x, y_cell, bar_funcs={nan_mean, sem}, bar_color={w_color, p_color, h_color})
ylabel(y_lab)
ylim(y_lim)
yline(100, '--k')

saveas(gcf, 'fig3.svg')
%% Plotting high Quinine
figure(4); clf;
sgtitle("High-quinine")
y = high_quinine;
y_lim = [0 100];

% male vs female
subplot(2,1,1); hold on
x = ["Male", "Female"];
y_cell = {y(is_male&sufficient_baseline), y(~is_male&sufficient_baseline)};
raw_data_error_bar(x, y_cell, bar_funcs={nan_mean, sem}, bar_color={m_color, f_color})
ylabel(y_lab)
ylim(y_lim)
yline(100, '--k')

% Wistar vs P vs HAD1
subplot(2,1,2); hold on
x = ["Wistar", "P", "HAD1"];
y_cell = {y(is_wis&sufficient_baseline), y(is_p&sufficient_baseline), y(is_had&sufficient_baseline)};
raw_data_error_bar(x, y_cell, bar_funcs={nan_mean, sem}, bar_color={w_color, p_color, h_color})
ylabel(y_lab)
ylim(y_lim)
yline(100, '--k')
saveas(gcf, 'fig4.svg')