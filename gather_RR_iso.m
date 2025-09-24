clear

%% Colors
 colors = colororder;

%% Load RR
path = 'C:\Users\daswyga\OneDrive - Indiana University\fMRI\data\MRI';
RR = loadRRcsvRecursive(path, '_RR.csv');
iso = loadRRcsvRecursive(path, '_iso.csv');
%% load start times from notes
start_times = readtable('C:\Users\daswyga\OneDrive - Indiana University\fMRI\data\MRI\start_times.csv');
start_times = start_times(logical(start_times.include),:);
%% convert RR time in relation to fMRI
% align and add RR to start times table
for i =1:height(start_times)
    start_times.rr(i) = RR.data(start_times.ID(i) == RR.id);
    start_times.iso(i) = iso.data(start_times.ID(i) == iso.id);
end

%% Interpolate times to common reference
[common_time, rates, iso] = common_rr_time(start_times);
common_time = common_time/60; % convert to minutes


%% Plot time vs. RR
% figure(1)
% imagesc(rates)
% c = colorbar;
% xlabel('time (s)')
% ylabel('rat number')
% c.Label.String = 'Respiratory rate';
%% resp rate and iso
figure(2);  theme('light'); clf; hold on

% respiratory rate on left y-axis
yyaxis left
shadedErrorBar(common_time,rates, {@mean,@sem}, 'lineProps',{'Color', colors(1,:), 'LineWidth',1.5})
ylabel('Respiratory rate (breaths/minute)', FontWeight='bold')
ylim([0,60])

% plot ISO% on right y-axis
yyaxis right
shadedErrorBar(common_time,iso, {@mean,@sem}, 'lineProps',{'Color', colors(2,:), 'LineWidth',1.5})
ylabel('Isoflurane %', FontWeight='bold')
ylim([0,2])

% time bars
plot_time_bars(start_times)

% x axis
xlabel('Time relative to fMRI start (minutes)', FontWeight='bold')
ax = gca;
ax.YAxis(1).FontWeight='bold';
ax.YAxis(2).FontWeight='bold';
ax.XAxis.FontWeight='bold';
xlim([-35 25])
%% normalized to rate at fMRI start
% norm_rate = rates ./ rates(:,common_time == 0);
% 
% figure(3);  theme('light'); clf; hold on
% shadedErrorBar(common_time,norm_rate, {@mean,@sem})
% xlabel('Time relative to fMRI start (s)')
% ylabel('Respiratory rate (normalized)')
% plot_time_bars(start_times)
% y_lim = ylim();
% ylim([0,y_lim(2)])


%%
function plot_time_bars(t)
t2_time = minutes(median(t.t2 - t.fMRI));
t2_time = [t2_time, t2_time + 12];

dti_time = minutes(median(t.dti - t.fMRI));
dti_time = [dti_time, dti_time + 12];

fMRI_time = [0, 24.5];

y_lim = ylim();
y = [y_lim(2),y_lim(2)];

plot(t2_time, y,'-', Color='black', LineWidth=2)
plot(dti_time, y,'-', Color='black', LineWidth=2)
plot(fMRI_time, y,'-', Color='black', LineWidth=2)

y = y(1);
text(mean(t2_time), y, 'T2', VerticalAlignment='bottom', HorizontalAlignment='center', FontWeight='bold')
text(mean(dti_time), y, 'DTI', VerticalAlignment='bottom', HorizontalAlignment='center', FontWeight='bold')
text(mean(fMRI_time), y, 'fMRI', VerticalAlignment='bottom', HorizontalAlignment='center', FontWeight='bold')

end


function [common_time, rates, iso] = common_rr_time(t)
    post_fmri = median(t.stop - t.fMRI);
    pre_fmri = median(t.dex - t.fMRI);
    common_time = seconds(pre_fmri):seconds(post_fmri);
    rates = nan(height(t), length(common_time));
    iso = rates;

    for i=1:height(t)

        row = t(i,:);

        rates(i,:) = parse_interp(row.rr{:}, row.fMRI, common_time);
        iso(i,:) = parse_interp(row.iso{:}, row.fMRI, common_time);
    end
end

function output =  parse_interp(t, ref, common_time)
    str_times = t.time;
    date_time = datetime(str_times, InputFormat='yyyyMMdd_HHmmss');
    fMRI_ref = timeofday(date_time)-timeofday(ref);
    fMRI_ref = seconds(fMRI_ref);
    y = t.note;

    %% remove nans
    fMRI_ref(isnan(y)) = [];
    y(isnan(y)) = [];

    % average duplicate times
    [unique_x, ~, group_idx] = unique(fMRI_ref);
    y = accumarray(group_idx, y, [], @mean);
    output = interp1(unique_x, y, common_time,'previous','extrap');
end

function numbers = strip_numbers_from_start(fileNames)
split_string = split(fileNames, "_");
numbers = str2double(split_string(:,1));
end

function output = loadRRcsvRecursive(folderPath, pattern)
    % Initialize output variables
    dataCell = {};
    fileNames = strings(0);

    % Call the recursive helper function
    [dataCell, fileNames] = searchFolder(folderPath, dataCell, fileNames, pattern);
    
    % Display summary
    fprintf('Loaded %d files from %s and its subdirectories.\n', length(fileNames), folderPath);

    id = strip_numbers_from_start(fileNames');
    data = dataCell';
    output = table(id,data);
end

function [dataCell, fileNames] = searchFolder(currentFolder, dataCell, fileNames, pattern)
    % Get list of all files and folders in current folder
    items = dir(currentFolder);

    for i = 1:length(items)
        item = items(i);
        fullPath = fullfile(currentFolder, item.name);

        if item.isdir
            % Skip '.' and '..' folders
            if ~strcmp(item.name, '.') && ~strcmp(item.name, '..')
                % Recurse into subdirectory
                [dataCell, fileNames] = searchFolder(fullPath, dataCell, fileNames, pattern);
            end
        elseif endsWith(item.name, pattern)
            % Load CSV file and store data
            try
                data = readtable(fullPath);
                dataCell{end+1} = data;
                fileNames(end+1) = item.name;
            catch ME
                warning('Failed to read %s: %s', fullPath, ME.message);
            end
        end
    end
end
