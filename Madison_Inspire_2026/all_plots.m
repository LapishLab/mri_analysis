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

%% Calculate metrics of interest
preference = ethanol ./ (ethanol+water);
E_per_kg = 0.1578 * ethanol ./ weight * 1000;
W_per_kg = 0.1578 * water ./ weight * 1000;

%% Prepare logical indices and colors for splitting rats
% Male vs. Female
is_male = strcmpi(rat_info.sex, "M");
m_color = 'blue';
f_color = 'red';

% Wistar vs. P vs. Had1
is_wis = strcmpi(rat_info.strain, "WISTAR");
is_p = strcmpi(rat_info.strain, "P");
is_had = strcmpi(rat_info.strain, "HAD1");

w_color = [0 1 1];
p_color = [1 0 1];
h_color = [1 1 0];

%% Prepare functions for plotting
sem = @(y) std(y, 'omitmissing') ./ sqrt(sum(~isnan(y)));
nan_mean = @(y) mean(y, "omitmissing");

%% %%%%%%%%%% Ethanol intake progression throughout IAP %%%%% 

% X-axis is all IAP days
is_IAP = day_info.duration==1440;
x = day_info.day(is_IAP);

% y-axis = preference (0-1)
    % y_lab = 'Ethanol preference';
    % y = preference(:, is_IAP);
    % y_lim = [0 1];
% y-axis = ethanol intake (mg/kg)
    y_lab = 'Ethanol intake (mg/kg)';
    y = E_per_kg(:, is_IAP);
    y_lim = [0 10];

% Plotting
clf;
% male vs female
subplot(2,1,1); hold on
shadedErrorBar(x, y(is_male,:), {nan_mean, sem}, 'lineProps', {'Color',m_color, 'DisplayName', 'Male'})
shadedErrorBar(x, y(~is_male,:), {nan_mean, sem}, 'lineProps', {'Color',f_color, 'DisplayName', 'Female'})
legend()
xlabel('Days')
ylabel(y_lab)
ylim(y_lim)

% Wistar vs P vs HAD1
subplot(2,1,2); hold on
shadedErrorBar(x, y(is_p,:), {nan_mean, sem}, 'lineProps', {'Color',p_color, 'DisplayName', 'P'})
shadedErrorBar(x, y(is_wis,:), {nan_mean, sem}, 'lineProps', {'Color',w_color, 'DisplayName', 'Wistar'})
shadedErrorBar(x, y(is_had,:), {nan_mean, sem}, 'lineProps', {'Color',h_color, 'DisplayName', 'HAD1'})
legend()
xlabel('Days')
ylabel(y_lab)
ylim(y_lim)

%% %%%%%%%%%% Transition from IAP->LAP and reaction to reduced time %%%%%
