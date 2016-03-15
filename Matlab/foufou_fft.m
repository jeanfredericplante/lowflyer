function [Y, f] = foufou_fft(samples, sample_freq)

sample_length = length(samples)
time_vector = (0:sample_length-1)*1/sample_freq
NFFT = 2^nextpow2(sample_length); % Next power of 2 from length of y
Y = fft(samples,NFFT)/sample_length;
f = sample_freq/2*linspace(0,1,NFFT/2+1);