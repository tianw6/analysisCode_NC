function seq = slideBins(dat, binWidth, interval)

% INPUTS:
%
% dat         - structure whose nth entry (corresponding to the nth experimental
%               trial) has fields
%                 trialId -- unique trial identifier
%                 spikes  -- 0/1 matrix of the raw spiking activity across
%                            all neurons.  Each row corresponds to a neuron.
%                            Each column corresponds to a 1 msec timestep.
% binWidth    - spike bin width in msec
%
%
%
% intervals   - time interval(milisecond) between each bins 
%               (from 1 to totalTime minus binWidth + 1)
% OUTPUTS:
%
% seq         - data structure, whose nth entry (corresponding to
%               the nth experimental trial) has fields
%                 trialId      -- unique trial identifier
%                 T (1 x 1)    -- number of timesteps
%                 y (yDim x T) -- neural data


  seq = [];
  for n = 1:length(dat)
    [yDim,tDim] = size(dat(n).spikes);
    
    % specify the end of each bin
    arr = [binWidth:interval:tDim];

    T = length(arr);
    seq(n).T       = T;
    seq(n).y       = nan(yDim, T);

    for t = 1:T
        % for each bin, calculate the start time and end time
        iStart = arr(t) - binWidth+1;
        iEnd = arr(t);
        % sum the spike counts within this time bin
        seq(n).y(:,t) = sum(dat(n).spikes(:, iStart:iEnd), 2);
    end
    
  end
  
  % Remove trials that are shorter than one bin width
  if ~isempty(seq)
    trialsToKeep = ([seq.T] > 0);
    seq = seq(trialsToKeep);
  end


end

