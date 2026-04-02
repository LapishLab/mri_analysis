IAP_eth_t = readtable("IAP_ethanol.csv", Delimiter=",");
IAP_wat_t = readtable("IAP_water.csv", Delimiter=",");
LAP_eth_t = readtable("LAP_ethanol.csv", Delimiter=",");
LAP_wat_t = readtable("LAP_water.csv", Delimiter=",");
rat_t = readtable("rats.csv", Delimiter=",");

%% convert to arrays (first grab dates from header)
date_str = IAP_eth_t.Properties.VariableNames;
IAP_eth = table2array(IAP_eth_t(:,2:end));
IAP_wat = table2array(IAP_wat_t(:,2:end));

LAP_eth = table2array(LAP_eth_t(:,2:end));
LAP_wat = table2array(LAP_wat_t(:,2:end));

%% concatonate IAP and LAP
eth = cat(2, IAP_eth, LAP_eth);
wat = cat(2, IAP_wat, LAP_wat);

n_IAP = size(IAP_eth,2);
n_LAP = size(LAP_eth,2);

%% get groupings
is_F = contains(rat_t.sex, 'F');
is_M = contains(rat_t.sex, 'M');
is_Wis = contains(rat_t.strain, 'Wistar');
is_Had = contains(rat_t.strain, 'HAD1');
is_P = contains(rat_t.strain, 'P');

%% M vs F - Ethanol & water
figure(1); clf
ymax = 11;
% ymax = 2;

subplot(1,2,1); hold on;
shadedErrorBar([],eth(is_M,:),{@nm,@sem}, 'lineProps', {'b'})
shadedErrorBar([],eth(is_F,:),{@nm,@sem}, 'lineProps', {'r'})
title('ethanol')
ylim([0,ymax])
ylabel('mg/kg')
xlabel('day')

xline(n_IAP, 'k--')
text(n_IAP/2, ymax, "24 hour access", VerticalAlignment="top")
text(n_IAP+n_LAP/2, ymax, ".3 h access", VerticalAlignment="top")
legend('M', 'F',Location='northwest')

subplot(1,2,2); hold on;
shadedErrorBar([],wat(is_M,:),{@nm,@sem}, 'lineProps', {'b'})
shadedErrorBar([],wat(is_F,:),{@nm,@sem}, 'lineProps', {'r'})
title('water')
ylim([0,ymax])
ylabel('mg/kg')
xlabel('day')

xline(n_IAP, 'k--')
text(n_IAP/2, ymax, "24 hour access", VerticalAlignment="top")
text(n_IAP+n_LAP/2, ymax, ".3 h access", VerticalAlignment="top")
exportgraphics(gcf, "sex_raw.png")
%% Strain - Ethanol & water
figure(2); clf
ymax = 12;
% ymax = 2;

subplot(1,2,1); hold on;
shadedErrorBar([],eth(is_Wis,:),{@nm,@sem}, 'lineProps', {'b'})
shadedErrorBar([],eth(is_P,:),{@nm,@sem}, 'lineProps', {'r'})
shadedErrorBar([],eth(is_Had,:),{@nm,@sem}, 'lineProps', {'g'})
title('ethanol')
ylim([0,ymax])

xline(n_IAP, 'k--')
text(n_IAP/2, ymax, "24 hour access", VerticalAlignment="top")
text(n_IAP+n_LAP/2, ymax, ".3 h access", VerticalAlignment="top")

legend('Wistar', 'P', 'HAD1', Location='northwest')
ylabel('mg/kg')
xlabel('day')

subplot(1,2,2); hold on;
shadedErrorBar([],wat(is_Wis,:),{@nm,@sem}, 'lineProps', {'b'})
shadedErrorBar([],wat(is_P,:),{@nm,@sem}, 'lineProps', {'r'})
shadedErrorBar([],wat(is_Had,:),{@nm,@sem}, 'lineProps', {'g'})
title('water')
ylim([0,ymax])
ylabel('mg/kg')
xlabel('day')

xline(n_IAP, 'k--')
text(n_IAP/2, ymax, "24 hour access", VerticalAlignment="top")
text(n_IAP+n_LAP/2, ymax, ".3 h access", VerticalAlignment="top")
exportgraphics(gcf, "strain_raw.png")
%% %%%%%%%%%%% normalize by time %%%%%%%%%%%%%%%
access_duration = [24*ones(1,n_IAP) , 1/3*ones(1,n_LAP)];
eth = eth ./ access_duration;
wat = wat ./ access_duration;

%% M vs F - Ethanol & water
figure(1); clf
ymax = 4;
% ymax = 2;

subplot(1,2,1); hold on;
shadedErrorBar([],eth(is_M,:),{@nm,@sem}, 'lineProps', {'b'})
shadedErrorBar([],eth(is_F,:),{@nm,@sem}, 'lineProps', {'r'})
title('ethanol')
ylim([0,ymax])
ylabel('mg/kg/h')
xlabel('day')

xline(n_IAP, 'k--')
text(n_IAP/2, ymax, "24 hour access", VerticalAlignment="top")
text(n_IAP+n_LAP/2, ymax, ".3 h access", VerticalAlignment="top")
legend('M', 'F',Location='northwest')

subplot(1,2,2); hold on;
shadedErrorBar([],wat(is_M,:),{@nm,@sem}, 'lineProps', {'b'})
shadedErrorBar([],wat(is_F,:),{@nm,@sem}, 'lineProps', {'r'})
title('water')
ylim([0,ymax])
ylabel('mg/kg/h')
xlabel('day')

xline(n_IAP, 'k--')
text(n_IAP/2, ymax, "24 hour access", VerticalAlignment="top")
text(n_IAP+n_LAP/2, ymax, ".3 h access", VerticalAlignment="top")
exportgraphics(gcf, "sex_h.png")

%% zoom in
subplot(1,2,2)
xlim([n_IAP-1, n_IAP+n_LAP])
subplot(1,2,1)
xlim([n_IAP-1, n_IAP+n_LAP])
exportgraphics(gcf, "sex_zoom.png")
%% Strain - Ethanol & water
figure(2); clf
ymax = 5.3;
% ymax = 2;

subplot(1,2,1); hold on;
shadedErrorBar([],eth(is_Wis,:),{@nm,@sem}, 'lineProps', {'b'})
shadedErrorBar([],eth(is_P,:),{@nm,@sem}, 'lineProps', {'r'})
shadedErrorBar([],eth(is_Had,:),{@nm,@sem}, 'lineProps', {'g'})
title('ethanol')
ylim([0,ymax])

xline(n_IAP, 'k--')
text(n_IAP/2, ymax, "24 hour access", VerticalAlignment="top")
text(n_IAP+n_LAP/2, ymax, ".3 h access", VerticalAlignment="top")

legend('Wistar', 'P', 'HAD1', Location='northwest')
ylabel('mg/kg/h')
xlabel('day')

subplot(1,2,2); hold on;
shadedErrorBar([],wat(is_Wis,:),{@nm,@sem}, 'lineProps', {'b'})
shadedErrorBar([],wat(is_P,:),{@nm,@sem}, 'lineProps', {'r'})
shadedErrorBar([],wat(is_Had,:),{@nm,@sem}, 'lineProps', {'g'})
title('water')
ylim([0,ymax])
ylabel('mg/kg/h')
xlabel('day')

xline(n_IAP, 'k--')
text(n_IAP/2, ymax, "24 hour access", VerticalAlignment="top")
text(n_IAP+n_LAP/2, ymax, ".3 h access", VerticalAlignment="top")

exportgraphics(gcf, "strain_h.png")
%% zoom in
subplot(1,2,2)
xlim([n_IAP-1, n_IAP+n_LAP])
subplot(1,2,1)
xlim([n_IAP-1, n_IAP+n_LAP])
exportgraphics(gcf, "strain_zoom.png")
%%
function score = nan_zscore(x, dim)
    avg = mean(x,dim, "omitmissing");
    stanDev = std(x, [], dim, "omitmissing");
    score = (x - avg) ./ stanDev;
end

function score = nan_dev(x, dim)
    avg = mean(x,dim, "omitmissing");
    score = x - avg;
end


function imnan(x)
im = imagesc(x);
alpha = ones(size(x));
alpha(isnan(x)) = 0;
im.AlphaData = alpha;
colorbar()
end

function avg = nm(x)
    avg = mean(x, 1, 'omitmissing');
end
function err = sem(x)
    err = std(x,[],1,"omitmissing") ./ sqrt(sum(~isnan(x)));
end