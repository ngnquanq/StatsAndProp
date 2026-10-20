"""Reproduce numerical solutions and figures: Python, NumPy, SciPy, Matplotlib."""
from pathlib import Path
import json
import os
os.environ.setdefault('MPLCONFIGDIR', '/tmp/exercise3-matplotlib')
import numpy as np
from scipy.stats import f, t, chi2, norm
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
ROOT = Path(__file__).resolve().parent
(ROOT/'figures').mkdir(exist_ok=True)
(ROOT/'generated').mkdir(exist_ok=True)
plt.rcParams.update({'font.family':'serif','font.size':10})
results = {}
def analyze(key, x=None, mean=None, S=None, n=None, mu0=None, alpha=.05):
    if x is not None:
        x = np.asarray(x, dtype=float)
        n, p = x.shape
        mean, S = x.mean(0), np.cov(x, rowvar=False)
    else:
        mean, S = np.asarray(mean,dtype=float), np.asarray(S,dtype=float)
        p = len(mean)
    assert np.linalg.eigvalsh(S).min()>0
    c = p*(n-1)/(n-p)*f.ppf(1-alpha,p,n-p)
    b = t.ppf(1-alpha/(2*p),n-1)
    se = np.sqrt(np.diag(S)/n)
    r = dict(n=n,p=p,mean=mean.tolist(),S=S.tolist(),critical=c,bonferroni=b,
             T_intervals=np.column_stack((mean-np.sqrt(c)*se,mean+np.sqrt(c)*se)).tolist(),
             B_intervals=np.column_stack((mean-b*se,mean+b*se)).tolist())
    if mu0 is not None:
        d=mean-np.asarray(mu0)
        T2=n*d@np.linalg.solve(S,d)
        r.update(mu0=list(mu0),T2=T2,F=T2*(n-p)/(p*(n-1)),
                 pvalue=f.sf(T2*(n-p)/(p*(n-1)),p,n-p),
                 direction=np.linalg.solve(S,d).tolist(),
                 likelihood_ratio=(1+T2/(n-1))**(-n/2))
    results[key]=r
    return r

def intervals_table(key):
    r=results[key]
    rows=[r'\begin{center}\begin{tabular}{ccc}\toprule',
          r'Tham số & Khoảng $T^2$ & Khoảng Bonferroni\\\midrule']
    for j,(a,b) in enumerate(zip(r['T_intervals'],r['B_intervals']),1):
        rows.append(fr'$\mu_{j}$ & $[{a[0]:.4f},\;{a[1]:.4f}]$ & $[{b[0]:.4f},\;{b[1]:.4f}]$\\')
    rows.append(r'\bottomrule\end{tabular}\end{center}')
    (ROOT/'generated'/f'{key}_intervals.tex').write_text('\n'.join(rows)+'\n')

def plot_region(key, indices=(0,1), critical=None, labels=None):
    r=results[key]
    ids=list(indices)
    m=np.array(r['mean'])[ids]
    S=np.array(r['S'])[np.ix_(ids,ids)]
    c=r['critical'] if critical is None else critical
    eig,U=np.linalg.eigh(S)
    theta=np.linspace(0,2*np.pi,700)
    curve=m[:,None]+U@(np.sqrt(c*eig/r['n'])[:,None]*np.array([np.cos(theta),np.sin(theta)]))
    fig,ax=plt.subplots(figsize=(5.8,4.2))
    ax.plot(*curve,color='black',label='95% ellipse')
    ax.plot(*m,'+',color='black')
    half=r['bonferroni']*np.sqrt(np.diag(S)/r['n'])
    lo,hi=m-half,m+half
    ax.plot([lo[0],hi[0],hi[0],lo[0],lo[0]], [lo[1],lo[1],hi[1],hi[1],lo[1]],
            '--',color='black',label='Bonferroni rectangle')
    if 'mu0' in r:
        ax.plot(*np.array(r['mu0'])[ids],'o',color='black',markersize=4,label=r'$\mu_0$')
    ax.set_xlabel(labels[0] if labels else fr'$\mu_{ids[0]+1}$')
    ax.set_ylabel(labels[1] if labels else fr'$\mu_{ids[1]+1}$')
    ax.legend(loc='best',fontsize=8,framealpha=1)
    fig.tight_layout()
    for suffix in ['pdf','png']:
        fig.savefig(ROOT/'figures'/f'{key}_ellipse.{suffix}',dpi=240)
    plt.close(fig)

def diagnostics(key,x,labels):
    from scipy.stats import probplot, shapiro
    from matplotlib.ticker import MaxNLocator
    import itertools
    p=x.shape[1]
    pairs=list(itertools.combinations(range(p),2))
    if p == 2:
        fig,axes=plt.subplots(1,3,figsize=(10,3.3))
        qqaxes, scatteraxes = axes[:2], axes[2:]
    else:
        fig,axes=plt.subplots(2,3,figsize=(10,6))
        qqaxes, scatteraxes = axes[0], axes[1]
    for j in range(p):
        (q,y),(slope,intercept,_) = probplot(x[:,j],dist='norm')
        ax=qqaxes[j]
        ax.plot(q,y,'o',color='black',ms=3)
        ax.plot(q,intercept+slope*q,color='black',lw=.8)
        ax.set(title=f'Q-Q: {labels[j]}',xlabel='Normal quantile',ylabel='Observed')
    for k,(i,j) in enumerate(pairs):
        ax=scatteraxes[k];ax.scatter(x[:,i],x[:,j],c='black',s=12)
        ax.set(xlabel=labels[i],ylabel=labels[j])
        ax.xaxis.set_major_locator(MaxNLocator(4))
        ax.yaxis.set_major_locator(MaxNLocator(5))
    fig.tight_layout()
    for suffix in ['pdf','png']:
        fig.savefig(ROOT/'figures'/f'{key}_diagnostics.{suffix}',dpi=200)
    plt.close(fig)
    results[key]['shapiro_pvalues']=[float(shapiro(x[:,j]).pvalue) for j in range(p)]

analyze('5_1',x=[[2,12],[8,9],[6,9],[8,10]],mu0=[7,11])
x=np.array([[6,9],[10,6],[8,3]],float)
C=np.array([[1,-1],[1,1]])
r=analyze('5_2',x=x,mu0=[9,5])
ry=analyze('5_2_Y',x=x@C.T,mu0=C@np.array([9.,5.]))
assert np.isclose(r['T2'],ry['T2'])
# Example 5.3 prints a more precise inverse than the displayed rounded S.
precision=np.array([[203.018,-163.391],[-163.391,200.228]])
r=analyze('5_5',mean=[.564,.603],S=np.linalg.inv(precision),n=42,mu0=[.55,.60])
d=np.array(r['mean'])-r['mu0']; a=precision@d
r['direction']=a.tolist()
r['univariate_t2']=42*(a@d)**2/(a@np.linalg.solve(precision,a))
assert np.isclose(r['T2'],r['univariate_t2'])
r['T2_using_rounded_S']=float(42*d@np.linalg.solve([[.0144,.0117],[.0117,.0146]],d))
plot_region('5_5')
for key,name,mu0,labels in [
 ('5_7','sweat',None,['Sweat rate','Sodium','Potassium']),
 ('5_18','college',[500,50,30],['Social/history','Verbal','Science']),
 ('5_19','lumber',[2000,10000],['Stiffness','Bending strength']),
 ('5_20','birds',[190,275],['Tail (mm)','Wing (mm)'])]:
    x=np.loadtxt(ROOT/'data'/f'{name}.csv',delimiter=',',skiprows=1)
    r=analyze(key,x=x,mu0=mu0)
    intervals_table(key)
    if key in ['5_18','5_19','5_20']: diagnostics(key,x,labels)
    if x.shape[1]==2:plot_region(key,labels=labels)
    if key=='5_18':
        vals,vecs=np.linalg.eigh(r['S']);order=np.argsort(vals)[::-1]
        vals,vecs=vals[order],vecs[:,order]
        # Fix signs for reproducible presentation.
        for j in range(3):
            if vecs[np.argmax(abs(vecs[:,j])),j]<0:vecs[:,j]*=-1
        r['eigenvalues']=vals.tolist();r['eigenvectors_columns']=vecs.tolist()
        r['half_axes']=np.sqrt(r['critical']*vals/r['n']).tolist()
        plot_region(key,critical=r['critical'])

mean=[95.52,164.38,55.69,93.39,17.98,31.13]
S=np.array([
[3266.46,1343.97,731.54,1175.50,162.68,238.37],
[1343.97,721.91,324.25,537.35,80.17,117.73],
[731.54,324.25,179.28,281.17,39.15,56.80],
[1175.50,537.35,281.17,474.98,63.73,94.85],
[162.68,80.17,39.15,63.73,9.95,13.88],
[238.37,117.73,56.80,94.85,13.88,21.26]])
r=analyze('5_9',mean=mean,S=S,n=61)
c=chi2.ppf(.95,6);se=np.sqrt(S.diagonal()/61)
r['critical']=float(c)
r['T_intervals']=np.column_stack((np.array(mean)-np.sqrt(c)*se,np.array(mean)+np.sqrt(c)*se)).tolist()
r['contrast_variance']=float(S[5,5]+S[4,4]-2*S[4,5])
h=t.ppf(1-.05/14,60)*np.sqrt(r['contrast_variance']/61)
r['contrast_interval']=[13.15-h,13.15+h]
intervals_table('5_9')
plot_region('5_9',indices=(0,3),critical=chi2.ppf(.95,2),labels=[r'$\mu_1$ (kg)',r'$\mu_4$ (cm)'])
(ROOT/'numerical_results.json').write_text(json.dumps(results,indent=2)+'\n')
print(json.dumps(results,indent=2))
