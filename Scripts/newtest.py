# Make plots appear inline, set custom plotting style
# matplotlib inline
import matplotlib.pyplot as plt
# plt.style.use('style/elegant.mplstyle')

import numpy as np

f = 10  # Frequency, in cycles per second, or Hertz
f_s = 100  # Sampling rate, or number of measurements per second

fig, ax = plt.subplots(4)

t = np.linspace(0, 2, 2 * f_s, endpoint=False)
x = np.sin(f * 2 * np.pi * t)

ax[0].plot(t, x)
ax[0].set_xlabel('Time [s]')
ax[0].set_ylabel('Signal amplitude');

# plt.show()

from scipy import fftpack

X = fftpack.fft(x)
freqs = fftpack.fftfreq(len(x)) * f_s

ax[1].stem(freqs, np.abs(X))
ax[1].set_xlabel('Frequency in Hertz [Hz]')
ax[1].set_ylabel('Frequency Domain (Spectrum) Magnitude')
ax[1].set_xlim(-f_s / 2, f_s / 2)
ax[1].set_ylim(-5, 110)

y = np.sin(f * 2 * np.pi * t + np.pi)

ax[2].plot(t, y)
ax[2].set_xlabel('Time [s]')
ax[2].set_ylabel('Signal amplitude');

Y = fftpack.fft(y)
freqs = fftpack.fftfreq(len(y)) * f_s

ax[3].stem(freqs, np.abs(Y))
ax[3].set_xlabel('Frequency in Hertz [Hz]')
ax[3].set_ylabel('Frequency Domain (Spectrum) Magnitude')
ax[3].set_xlim(-f_s / 2, f_s / 2)
ax[3].set_ylim(-5, 110)

plt.show()