%ATSD project
%Jacopo Tancredi 19/20/2020

close all;
clear all;

LPC_order = 30;

%request user input for wav file ('name')
prompt = 'Name of the wav? ';
filename = strcat(input(prompt),'.wav');

%Load the audio file.
[x, Fs]   = audioread(filename);

%Playing the audio file.
sound(x);

%Trying to reduce the noise.
x         = movmean(x, 4);

%Plot the audio trace.
figure();
plot  (x);
xlabel('n');
ylabel('x[n]');
title ('Audio trace');

%Define the window.
window    = blackman(128);

%Plot the spectrogram of the audio trace.
figure     ();
spectrogram(x, window, 64, 256, Fs, 'yaxis');
title      ('Spectrogram of the audio trace');

%Extract the 'Z' consonant.

start_y   = int32(input('Start '));
end_y     = int32(input('End '));
n         = start_y:end_y;
y         = x(n);

%Plot the segmented audio trace.
figure();
plot  (y);
xlabel('n');
ylabel('y[n]');
title ('Segmented Audio trace');

%Playing the segmented audio trace.
sound(y);

%Plot the spectrogram of the segmented audio trace.
figure     ();
spectrogram(y, window, 64, 256, Fs, 'yaxis');
title      ('Spectrogram of the segmented audio trace');

%Computation of the linear predictive coding.
[a, p0]   = lpc(y, LPC_order);

%Gaussian white noise generation and estimation.
noise     = sqrt(p0)*randn(length(y), 1);

est_y     = filter(1, a, noise);
e         = y - est_y;

%Plot the estimation error.
figure();
plot  (n, e, '-k');
axis  ([start_y end_y min(e)-1 max(e)+1]);
xlabel('n');
ylabel('e[n]');
title ('Estimation error');

%Plot the segmented audio trace and its estimation.
figure();
plot  (n, y, '-b', n, est_y, '--r');
xlabel('n');
ylabel('x[n]/y[n]');
title ('Segmented audio trace and its estimation.');
legend('Segmented audio trace', 'Estimation');

%Plot the spectrogram of the estimation.
figure     ();
spectrogram(est_y, window, 64, 256, Fs, 'yaxis');
title      ('Spectrogram of the estimation');

%Welch periodograms.
Wlen      = 128;
Nfft      = 256;
Pyy       = pwelch(y,     blackman(Wlen), 64, Nfft);
Pee       = pwelch(est_y, blackman(Wlen), 64, Nfft);
Wp        = linspace(0, 4, length(Pyy));

%Plot the Welch periodograms.
figure();
plot  (Wp, 20*log10(Pyy), 'b-', Wp, 20*log10(Pee), 'r--');
xlabel('Frequency (kHz)');
ylabel('dB');
legend('Real', 'Estimated');
title ('Welch periodogram');

%Playing the estimated segmented audio trace.
sound(est_y);


%Linear Prediction
a_ext     = lpc(est_y, LPC_order);
predictor = filter(-a_ext,1,est_y);

figure();
plot  (n, est_y, '-b', n, predictor, 'ro');
xlabel('n');
ylabel('x[n]/y[n]');
title ('AR model as predictor.');
legend('AR', 'Extimation');