 function [] = plotBeautiful(cal_mean,cal_sem,test_mean,test_sem,cal_y,test_y,test_raw,xC,xH,subjectName,run,type,PLOT,outputFolder)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

% xC = 0.5:2:21.5;
% xH_orig = [0.5 1:blockVolsH-1 blockVolsH-0.5];
% aldrabice!!
% switch s_adjust
%     case 1
%         xH = 1:(blockVolsH-s_adjust);
%     case 2
%         xH = 1.5:(blockVolsH-s_adjust+0.5);
%     case 3
%         xH = 2:(blockVolsH-s_adjust+1);
% end

switch type
    case 'cp'
%         ggg = {'0','5','10','15','20','25','30','35','40','45','50','55','60','65','70','75','80','85','90','95','100'};
        ggg = 0:5:100;
        lll = 'northwest';
    case 'pc'
        cal_mean = cal_mean(end:-1:1);
        cal_sem = cal_sem(end:-1:1);
        cal_y = cal_y(end:-1:1);
%         ggg = {'100','95','90','85','80','75','70','65','60','55','50','45','40','35','30','25','20','15','10','5','0'};
        ggg = 100:-5:0;
        lll = 'northeast';
end

dot_styles = {'s','o','+','^'};
nTrials = size(test_raw,1);

%% Possible plot
fig1 = figure('Position',[100 100 1100 500]);

% Axis for dots percentage
b=axes('Position',[.1 .1 .8 1e-12]);
set(b,'Units','normalized');

% Axis for time in volumes
a=axes('Position',[.1 .22 .8 .7]);
set(a,'Units','normalized');

% Plots in axis a
plot(a,xC,cal_mean,'.','Color',[0.9 0.1 0.1],'MarkerSize',10); hold on; % calibration
plot(a,xH,test_mean,'.','Color',[0 0.4 0.5],'MarkerSize',15); hold on; % testing dots
errorbar(a,xC,cal_mean,cal_sem,'LineStyle','--','Color',[0.9 0.1 0.1]); hold on; % calibration SEM
errorbar(a,xH,test_mean,test_sem,'LineStyle','--','Color',[0 0.4 0.5]); hold on; % testing SEM
plot(a,xC,cal_y,'r-',xH,test_y,'b-','LineWidth',1.5); hold on; % sigmoid fits
for jj = 1:nTrials
    aux = mod(jj,4); if aux==0; aux = 4;end
    plot(a,xH,test_raw(jj,:),dot_styles{aux},'Color',[0 0.4 0.6]); hold on; % testing data points
end
plot(a,[-0.025 1.025],0.5*ones(1,2),'b-.'); hold off; % y=50 line

% Adjust limits ticks labels
set(b,'xlim',[-0.025 1.025]);
set(b,'xtick',0:0.05:1)
set(b,'xticklabels',ggg);
xlabel(b,'% of dots moving vertically')
set(a,'xlim',[-0.025 1.025],'ylim',[-0.05 1.05]);
set(a,'xtick',0:0.05:1)
set(a,'xticklabels',1:21);
xlabel(a,'Time (volumes)')
ylabel(a,'% of down reports')
grid on;

title(sprintf('S: %s - %s - %s',subjectName,run,type))
legend({'Calibration','Testing','CalibrationLine','TestingLine','Fit Cal','Fit Test'},'Location',lll)

if PLOT
%     outputFolder = fullfile('E:\Google Drive\GitHub_DATA\ICNAS_VisualPerception\Hysteresis_Paper\output_sigmoidfit');
    print(fig1,fullfile(outputFolder,sprintf('%s_%s_%s',type,subjectName,run)),'-dpng')
    close(fig1)
end

end
