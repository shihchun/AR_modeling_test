# with matplotlib + pandas
import pandas as pd
import matplotlib.pyplot as plt
df = pd.read_csv('./test.csv')
fig = df.plot(x=df.columns[0], y=df.columns[1:])
#plt.show() # 也可以直接用到這裏下面註解

from plotly.offline.offline import plot_mpl
plot_mpl(fig.get_figure(), filename='temp-plot.html', auto_open=False)
# more setting with plotly
fig = fig.get_figure()
from plotly.tools import mpl_to_plotly
plotly_fig = mpl_to_plotly(fig)
plotly_fig.update_layout(template="none",showlegend=True,annotations=[dict(visible=False)])
plotly_fig.write_html("temp-plot.html")