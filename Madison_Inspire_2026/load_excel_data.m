function [W, E, weight, day_info, rat_info] = load_excel_data()
%% Load LAP data
[LAP_W, LAP_E, LAP_weight, LAP_days] = load_consumption("LAP_consumption.xlsx", 'B2:T61');
LAP_days.duration(:) = 20;

%% Load IAP data
[IAP_W, IAP_E, IAP_weight, IAP_days] = load_consumption("IAP_consumption.xlsx", 'B2:AK61');
IAP_days.duration(:) = 24*60;

%% merge IAP and LAP
W = cat(2, IAP_W, LAP_W);
E = cat(2, IAP_E, LAP_E);
weight = cat(2, IAP_weight, LAP_weight);
day_info = cat(1, IAP_days, LAP_days);

%% Load rat info
rat_info = readtable("rat_info.xlsx", sheet="all");
rat_info = rat_info(1:60,:);
rat_info.sex = upper(string(rat_info.sex));
rat_info.strain = upper(string(rat_info.strain));
end


function t = load_string_table(path, sheet)
    opts = detectImportOptions(path, Sheet=sheet);
    opts = setvartype(opts, opts.SelectedVariableNames, 'string');
    opts.DataRange = 'A1';
    opts.VariableNamesRange = ''; 
    t = readtable(path, opts, 'ReadVariableNames', false);
end

function [W, E, weight, day_conditions] = load_consumption(path, range)
    W = readmatrix(path, 'Sheet', 'W_g', 'Range', range);
    E = readmatrix(path, 'Sheet', 'E_g', 'Range', range);
    weight = readmatrix(path, 'Sheet', 'rat_weight', 'Range', range);
    notes = load_string_table(path, "notes");
    
    q_notes = string(notes{2:5,2:end});
    q_notes = extractAfter(extractBefore(q_notes,"uM quinine"), "+");
    q_vals = double(q_notes);
    q_vals(isnan(q_vals)) = 0; % Nan mean 0 quinine was delivered

    %%
    dates = datetime(notes{1,2:end});
    %%
    
    day_conditions = table();
    day_conditions.date = dates';
    day_conditions.quinine_r1_30 = max(q_vals(1:2, :))';
    day_conditions.quinine_r31_60 = max(q_vals(3:4, :))';

end