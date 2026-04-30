
function plotPsychAndChrono(summary, axPsych, axRT, yLimRT)
%
%   plotPsychAndChrono(summary, axPsych, axRT, yLimRT)
%
%   Plots the psychometric and chronometric curves given a summary data
%   structure onto pre-existing axes.
%
%        summary   - struct with fields:
%                      rawdata.pRed, rawdata.RT
%                      params (Color, CI, lineWidth, markerSize)
%        axPsych   - axes handle for the psychometric curve
%        axRT      - axes handle for the chronometric curve
%        yLimRT    - [yMin yMax] for the RT axis
%
% Pierre Boucher and Chand Chandrasekaran, January 2022
% Refactored: axes formatting moved to caller

params = summary.params;

pRed = summary.rawdata.pRed;
RT   = summary.rawdata.RT;

summary.pRed     = squeeze(nanmean(pRed));
summary.pRedError = squeeze(nanstd(pRed)) ./ sqrt(size(pRed, 1));

summary.RT  = squeeze(nanmean(RT));
summary.RTe = squeeze(nanstd(RT))  ./ sqrt(size(RT,  1));

% --- Psychometric curve ---
axes(axPsych);
errorbar(summary.signedColorCoherence, summary.pRed, ...
    params.CI * summary.pRedError, ...
    'o-', 'color', params.Color, ...
    'linewidth', params.lineWidth, ...
    'markersize', params.markerSize, ...
    'MarkerFaceColor', [0.4 0.4 0.4]);

% --- Chronometric curve ---
axes(axRT);
errorbar(summary.signedColorCoherence, summary.RT, ...
    params.CI * summary.RTe, ...
    'o-', 'color', params.Color, ...
    'linewidth', params.lineWidth, ...
    'markersize', params.markerSize, ...
    'MarkerFaceColor', [0.4 0.4 0.4]);
ylim(yLimRT);

