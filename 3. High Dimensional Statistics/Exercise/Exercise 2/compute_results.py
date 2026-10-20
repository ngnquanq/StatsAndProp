"""Recompute Exercise 2 numerical answers and monochrome figures.

Run with Python + NumPy, SciPy, Matplotlib. All data are transcribed from
the three supplied exercise images; the unusual values 287 and 168 are retained.
"""
from pathlib import Path
import os
import json

os.environ.setdefault("MPLCONFIGDIR", "/tmp/exercise2-matplotlib")
import numpy as np
from scipy.stats import f, t, chi2, norm
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parent
(ROOT/"figures").mkdir(exist_ok=True)
plt.rcParams.update({"font.family": "serif", "font.size": 10})

def ellipse(ax, mean, covariance, n, critical, label):
    values, vectors = np.linalg.eigh(covariance)
    angle = np.linspace(0, 2*np.pi, 600)
    curve = mean[:, None] + vectors @ (np.sqrt(critical*values/n)[:, None]
                                      * np.array([np.cos(angle), np.sin(angle)]))
    ax.plot(*curve, color="black", label=label)
    ax.plot(*mean, "+", color="black")

def rectangle(ax, mean, half, label):
    lo, hi = mean-half, mean+half
    ax.plot([lo[0],hi[0],hi[0],lo[0],lo[0]],
            [lo[1],lo[1],hi[1],hi[1],lo[1]], "--", color="black", label=label)

results = {}
x1 = np.array([[2,12],[8,9],[6,9],[8,10]], dtype=float)
m1, s1 = x1.mean(0), np.cov(x1, rowvar=False)
d1 = m1 - [7,11]
t1 = 4*d1 @ np.linalg.solve(s1,d1)
results["3.1"] = dict(mean=m1.tolist(), S=s1.tolist(), T2=t1,
    F=t1/3, critical=3*f.ppf(.95,2,2), p_value=f.sf(t1/3,2,2))
x2 = np.array([[6,9],[10,6],[8,3]], dtype=float)
C = np.array([[1,-1],[1,1]])
y = x2 @ C.T
results["3.2"] = dict(mean=x2.mean(0).tolist(), S=np.cov(x2,rowvar=False).tolist(),
    Y=y.tolist(), mean_Y=y.mean(0).tolist(), S_Y=np.cov(y,rowvar=False).tolist())
# Exercise 3.3 uses Exercise 3.1, as clarified: two variables, four observations.
n3, p3 = x1.shape
k3 = p3*(n3-1)/(n3-p3)*f.ppf(.95,p3,n3-p3)
b3 = t.ppf(1-.05/(2*p3),n3-1)
se3 = np.sqrt(np.diag(s1)/n3)
results["3.3"] = dict(n=n3, p=p3, mean=m1.tolist(), S=s1.tolist(),
    critical=k3, bonferroni_t=b3,
    T_intervals=np.column_stack((m1-np.sqrt(k3)*se3,m1+np.sqrt(k3)*se3)).tolist(),
    B_intervals=np.column_stack((m1-b3*se3,m1+b3*se3)).tolist(),
    length_ratio=np.sqrt(k3)/b3)
n4, m4 = 42, np.array([.564,.603])
s4 = np.array([[.0144,.0117],[.0117,.0146]])
k4 = 2*41/40*f.ppf(.95,2,40)
d4 = np.array([.60,.58])-m4
t4 = n4*d4 @ np.linalg.solve(s4,d4)
h4 = np.sqrt(k4*np.diag(s4)/n4)
results["3.4"] = dict(MLE=(s4*41/42).tolist(), inverse=np.linalg.inv(s4).tolist(),
    critical=k4, T2=t4, F=t4*40/82, p_value=f.sf(t4*40/82,2,40),
    intervals=np.array([m4-h4,m4+h4]).T.tolist())

# Each source row contains three birds, each represented by (tail, wing).
rows = np.array([
 [191,284,186,266,173,271], [197,285,197,285,194,280],
 [208,288,201,295,198,300], [180,273,190,282,180,272],
 [180,275,209,305,190,292], [188,280,287,285,191,286],
 [210,283,207,297,196,285], [196,288,178,168,207,286],
 [191,271,202,271,209,303], [179,257,205,285,179,261],
 [208,289,190,280,186,262], [202,285,189,277,174,245],
 [200,272,211,310,181,250], [192,282,216,305,189,262],
 [199,280,189,274,188,258],
])
x5 = rows.reshape(-1,2)
n5 = len(x5)
m5, s5 = x5.mean(0), np.cov(x5,rowvar=False)
k5 = 2*44/43*f.ppf(.95,2,43)
bt5 = t.ppf(1-.05/4,44)
h5, b5 = np.sqrt(k5*np.diag(s5)/n5), bt5*np.sqrt(np.diag(s5)/n5)
d5 = m5 - [190,275]
t5 = n5*d5 @ np.linalg.solve(s5,d5)
results["3.5"] = dict(n=n5, mean=m5.tolist(), S=s5.tolist(), inverse=np.linalg.inv(s5).tolist(),
    critical=k5, bonferroni_t=bt5, T2=t5, p_value=f.sf(t5*43/88,2,43),
    T_intervals=np.array([m5-h5,m5+h5]).T.tolist(),
    B_intervals=np.array([m5-b5,m5+b5]).T.tolist())
fig,ax = plt.subplots(figsize=(5.7,4))
ellipse(ax,m5,s5,n5,k5,"95% Hotelling ellipse")
rectangle(ax,m5,b5,"95% Bonferroni rectangle")
ax.plot(190,275,"o",color="black",markersize=4,label=r"$\mu_0=(190,275)'$")
ax.set(xlabel=r"$\mu_1$ (mm)",ylabel=r"$\mu_2$ (mm)")
ax.legend(fontsize=8)
fig.tight_layout()
fig.savefig(ROOT/"figures/bai35_ellipse.pdf")
fig.savefig(ROOT/"figures/bai35_ellipse.png", dpi=300)
plt.close(fig)

m6 = np.array([95.52,164.38,55.69,93.39,17.98,31.13])
s6 = np.array([
 [3266.46,1343.97,731.54,1175.50,162.68,238.37],
 [1343.97,721.91,324.25,537.35,80.17,117.73],
 [731.54,324.25,179.28,281.17,39.15,56.80],
 [1175.50,537.35,281.17,474.98,63.73,94.85],
 [162.68,80.17,39.15,63.73,9.95,13.88],
 [238.37,117.73,56.80,94.85,13.88,21.16],
])
se6 = np.sqrt(np.diag(s6)/61)
k6 = chi2.ppf(.95,6)
b6,b7 = t.ppf(1-.05/12,60), t.ppf(1-.05/14,60)
z6,z7 = norm.ppf(1-.05/12),norm.ppf(1-.05/14)
sub = s6[np.ix_([0,3],[0,3])]
diffse = np.sqrt((s6[5,5]+s6[4,4]-2*s6[5,4])/61)
results["3.6"] = dict(chi6=k6, chi2=chi2.ppf(.95,2), t6=b6, t7=b7,z6=z6,z7=z7,
    simultaneous=np.array([m6-np.sqrt(k6)*se6,m6+np.sqrt(k6)*se6]).T.tolist(),
    bonferroni=np.array([m6-b6*se6,m6+b6*se6]).T.tolist(),
    bonferroni_z=np.array([m6-z6*se6,m6+z6*se6]).T.tolist(),
    sub_inverse=np.linalg.inv(sub).tolist(), diff_se=diffse,
    diff_interval=[m6[5]-m6[4]-b7*diffse,m6[5]-m6[4]+b7*diffse],
    diff_interval_z=[m6[5]-m6[4]-z7*diffse,m6[5]-m6[4]+z7*diffse])
fig,ax = plt.subplots(figsize=(5.7,4))
ellipse(ax,m6[[0,3]],sub,61,chi2.ppf(.95,2),"95% ellipse (2 variables)")
rectangle(ax,m6[[0,3]],b6*se6[[0,3]],"Bonferroni rectangle (6 means)")
ax.set(xlabel=r"$\mu_1$ (kg)",ylabel=r"$\mu_4$ (cm)")
ax.legend(fontsize=8)
fig.tight_layout()
fig.savefig(ROOT/"figures/bai36_ellipse.pdf")
fig.savefig(ROOT/"figures/bai36_ellipse.png", dpi=300)
plt.close(fig)

for a in [s1,s4,s5,s6]:
    assert np.linalg.eigvalsh(a).min() > 0
mu0 = np.array([1.5,-2.])
dx,dy = x2.mean(0)-mu0,y.mean(0)-C@mu0
assert np.isclose(3*dx@np.linalg.solve(np.cov(x2,rowvar=False),dx),
                  3*dy@np.linalg.solve(np.cov(y,rowvar=False),dy))
assert n5 == 45
(ROOT/"numerical_results.json").write_text(json.dumps(results,indent=2)+"\n")
print(json.dumps(results,indent=2))
