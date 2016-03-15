% analyze flyer data
clear all, close all
filename = 'C:\Users\JFP Windows\Downloads\samples_open_4_17_3.txt';
import_data_complete;

samples = ma;
sample_freq = -1/mean(diff(tm));
time_vector = (0:length(samples)-1)*1/sample_freq;
max_freq = 5;
min_freq = 0.5;

[Y,f] = foufou_fft(samples, sample_freq);

%% Analysis 1
close(findobj('type','figure','name','magneto summary'))
figure('Name','magneto summary')
subplot(211)
plot(time_vector, samples); grid
title('Raw magnetic signal')
xlabel('time seconds')

subplot(212)
idx = find(f> min_freq & f < max_freq);
bar(f(idx),2*abs(Y(idx)));grid
title('FFT')
xlabel('Frequency (Hz)')
ylabel('|Magnetic (f)|')

%% Finding the max and 2nd harmonic
peak_window = gausswin(4)
close(findobj('type','figure','name','peak detection'))
figure('Name','peak detection')
subplot (211)
idx = find(f> min_freq & f < max_freq)
r = xcorr(abs(Y(idx)),peak_window)
r = r(length(idx):end)
bar(f(idx), r);;grid;

subplot(212)
idx = find(f> min_freq & f < max_freq);
bar(f(idx),2*abs(Y(idx)));grid
title('FFT')
xlabel('Frequency (Hz)')
ylabel('|Magnetic (f)|')

% 
% close(findobj('type','figure','name','magnetometer signals'))
% figure('Name','magnetometer signals')
% subplot(511)
% plot(time_vector, samples); grid;
% ylabel('Raw magneto amp')
% 
% 
% subplot(512)
% plot(time_vector, mx); grid
% ylabel('Raw magneto x')
% 
% 
% subplot(513)
% plot(time_vector, my); grid
% ylabel('Raw magneto y')
% 
% subplot(514)
% plot(time_vector, mz); grid
% ylabel('Raw magneto z')
% xlabel('time seconds')
% 
% subplot(515)
% idx = find(f> min_freq & f < max_freq);
% plot(f(idx),2*abs(Y(idx))); grid
% title('FFT')
% xlabel('Frequency (Hz)')
% ylabel('|Magnetic (f)|')
% 
% %% Analysing the accelerometer signal
% 
% 
% samples = aa;
% sample_freq = -1/mean(diff(ta));
% time_vector = (0:length(samples)-1)*1/sample_freq;
% max_freq = 10;
% min_freq = 0.0;
% 
% [Y,f] = foufou_fft(samples, sample_freq);
% 
% close(findobj('type','figure','name','accelerometer signal'))
% figure('Name','accelerometer signal')
% subplot(511)
% plot(time_vector, samples); grid
% ylabel('Raw accelerometer amp')
% 
% 
% subplot(512)
% plot(time_vector, ax); grid
% ylabel('Raw accelerometer x')
% 
% 
% subplot(513)
% plot(time_vector, ay); grid
% ylabel('Raw accelerometer y')
% 
% subplot(514)
% plot(time_vector, az); grid
% ylabel('Raw accelerometer z')
% xlabel('time seconds')
% 
% subplot(515)
% idx = find(f> min_freq & f < max_freq);
% plot(f(idx),2*abs(Y(idx)));grid
% title('FFT')
% xlabel('Frequency (Hz)')
% ylabel('|Magnetic (f)|')

%% Analyzing the magneto signal