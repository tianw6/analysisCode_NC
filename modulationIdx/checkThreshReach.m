function [reachThresh] = checkThreshReach(TOI,left, right,red, green, FRthresh)

RL = TOI(:,:,left == 1 & red == 1);
RR = TOI(:,:,right == 1 & red == 1);
GL = TOI(:,:,left == 1 & green == 1);
GR = TOI(:,:,right == 1 & green == 1);

aa = squeeze(mean(RL, 3));
bb = squeeze(mean(RR, 3));
cc = squeeze(mean(GL, 3));
dd = squeeze(mean(GR, 3));

reachThresh = max(aa, [], 2) > FRthresh | max(bb, [], 2) > FRthresh | max(cc, [], 2) > FRthresh | max(dd, [], 2) > FRthresh;

end

