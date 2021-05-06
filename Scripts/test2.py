# Make plots appear inline, set custom plotting style
# matplotlib inline
import matplotlib.pyplot as plt
# plt.style.use('style/elegant.mplstyle')

import numpy as np

L = 1805.231  # Total length of data in seconds
f_s = 360.065  # Sampling rate, or number of measurements per second

t = np.linspace(0, L, L * f_s, endpoint=False)
x = 

fig, ax = plt.subplots(2)
ax[0].plot(t, x)
ax[0].set_xlabel('Time [s]')
ax[0].set_ylabel('Signal amplitude');

# plt.show()

from scipy import fftpack

X = fftpack.fft(x)
freqs = fftpack.fftfreq(len(x)) * f_s

# fig, ax = plt.subplots()

ax[1].stem(freqs, np.abs(X))
ax[1].set_xlabel('Frequency in Hertz [Hz]')
ax[1].set_ylabel('Frequency Domain (Spectrum) Magnitude')
ax[1].set_xlim(-f_s / 2, f_s / 2)
ax[1].set_ylim(-5, 110)

plt.show()