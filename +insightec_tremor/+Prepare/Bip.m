function bip = Bip
global S

%% Parameters

fs  = S.Parameters.Audio.SamplingRate;
f0  = S.Parameters.insightec_tremor.Bip.Freq;
dur = S.Parameters.insightec_tremor.Bip.BipDuration;
iof = S.Parameters.insightec_tremor.Bip.InOutFadeRation;


%% Create objects

bip = Bip( fs , f0 , dur , iof );
bip. LinkToPAhandle( S.PTB.Playback_pahandle );
bip.AssertReadyForPlayback; % just to check


end % function
