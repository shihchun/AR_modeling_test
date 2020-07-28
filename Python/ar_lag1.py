import numpy as np
import matplotlib.pyplot as plt 

# sampling parameters
f = 100
endtime = 100 # 時間長度
seq = 100 # test seq length for predition
lagt = 1 # lag 幾秒
N = f*(endtime+seq) # sample 數量 看f
t = np.linspace(1,endtime+seq,N)


# 找lag幾個sample
count = 0
while (count <= len(t)):
    if t[count] >= lagt:
        lag = count+1; break

# # gaussian noise
e = np.random.randn( len(t) )
e = e / np.max(e)
# signal
A = 0.5
xt = np.sin(2 * np.pi * f * t) + A * e
# AR model seqs [lag endtime]
a1 = [0.1] # close to 0
x1 = np.zeros(N)
for i in range(lag, len(t)):
    x1[i] = a1[0] * xt[i-1] + xt[i-1]
    if t[i]>=endtime:
        split_ind = i
        break
    pass
# this AR model based on kalman filte
# https://www.statsmodels.org/stable/_modules/statsmodels/tsa/ar_model.html#AR.fit
from statsmodels.tsa.ar_model import AR
# split dataset
x = xt[:split_ind] # data to fit
y = xt[split_ind:] # data to test

# autoregressive model
p = 50 # AR model order
model = AR(x)
model_fit = model.fit(maxlag=p) # unconditional maximum likelihood

# make predictions
start = len(x)
stop  = len(x) + len(y) - 1
u = model_fit.predict(start, stop) # Kalman filter 


# plot from scratch
fig = plt.figure()
plt.subplot(2, 1, 1)
plt.plot(t,xt,label="original")
plt.plot(t,x1,label="AR(1)")
plt.xlabel('time')
plt.ylabel('e, x') 
plt.legend(['xt', 'AR(1)'], loc='best')
# plot from lib
plt.subplot(2, 1, 2)
plt.plot(t[:start], x, 'k', linewidth=2, label="original")
plt.plot(t[start:(stop + 1)], y, linewidth=2, label='expected')
plt.plot(t[start:(stop + 1)], u, linewidth=2, label='predicted')
plt.plot([t[start], t[start]], [-1, 1], 'r--', linewidth=3,label="分割線")
plt.xlim(t[0], t[-1])
plt.ylim(-2, 2)
plt.legend()

from plotly.offline.offline import plot_mpl
plot_mpl(fig, filename='temp-plot.html', auto_open=False)
# more setting with plotly
from plotly.tools import mpl_to_plotly
plotly_fig = mpl_to_plotly(fig)
plotly_fig.update_layout(template="none",showlegend=True,annotations=[dict(visible=False)])
plotly_fig.write_html("temp-plot.html")