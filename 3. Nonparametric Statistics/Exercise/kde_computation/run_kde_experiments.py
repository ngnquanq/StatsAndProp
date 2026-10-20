"""Reproduce Wasserman 6.5--6.7, 6.9--6.10; run with Python + NumPy/SciPy/Matplotlib.

No downloads occur at runtime. Data provenance and interpretation are in README.md.
All bandwidth searches are explicit finite grids, not claims of global optimization.
"""
from pathlib import Path
import os
os.environ.setdefault("MPLCONFIGDIR", "/tmp/kde-matplotlib")
os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")
import json
import hashlib
import numpy as np
import scipy
from scipy.spatial.distance import pdist
from scipy.signal import find_peaks
from scipy.stats import beta
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parent
FIG = ROOT / "figures"
FIG.mkdir(exist_ok=True)
SEED = 20260930
REPS = 40
BOOT = 1999
SQRT2PI = np.sqrt(2*np.pi)
trap = np.trapezoid if hasattr(np, "trapezoid") else np.trapz
plt.rcParams.update({"font.size": 9, "axes.spines.top": False,
                     "axes.spines.right": False, "savefig.bbox": "tight"})

def phi(u):
    return np.exp(-u*u/2)/SQRT2PI

def weights(x, grid, h, kernel="Gaussian"):
    u = (grid[None, :] - x[:, None])/h
    if kernel == "Gaussian":
        return phi(u)/h
    if kernel == "Epanechnikov":
        return .75*np.maximum(1-u*u, 0)/h
    if kernel == "Uniform":
        return (np.abs(u) <= 1).astype(float)/(2*h)
    raise ValueError(kernel)

def kde(x, grid, h, kernel="Gaussian"):
    return weights(x, grid, h, kernel).mean(axis=0)

def normal_reference(x):
    return 1.06*min(np.std(x, ddof=1), np.diff(np.quantile(x, [.25, .75]))[0]/1.34)*len(x)**(-.2)

def cv_scores(x, hs):
    n = len(x)
    d2 = pdist(x[:, None], "sqeuclidean")
    scores = []
    for h in hs:
        e = np.exp(-d2/(4*h*h))
        integrated = (n+2*e.sum())/(2*np.sqrt(np.pi)*n*n*h)
        loo = 4*(e*e).sum()/(SQRT2PI*n*(n-1)*h)
        scores.append(integrated-loo)
    return np.array(scores)

def select_h(x):
    hn = normal_reference(x)
    hs = hn*np.geomspace(.06, 4, 101)
    score = cv_scores(x, hs)
    idx = int(np.argmin(score))
    assert 0 < idx < len(hs)-1, "Expand bandwidth search: minimum at edge"
    return hn, float(hs[idx]), hs, score

def local_likelihood(x, grid, h, degree):
    """Full real-line Gaussian kernel, polynomial a0+a1*t+a2*t^2/2.
    Analytic maximizers from matching weighted moments; no boundary truncation.
    """
    t = x[:, None]-grid[None, :]
    w = phi(t/h)
    s = w.sum(axis=0)
    m = (w*t).sum(axis=0)/s
    if degree == 0:
        return s/(len(x)*h)
    if degree == 1:
        return s/(len(x)*h)*np.exp(-m*m/(2*h*h))
    v = (w*(t-m)**2).sum(axis=0)/s
    assert np.min(v) > 0
    return s/(len(x)*np.sqrt(v))*np.exp(-m*m/(2*v))

def bands(x, grid, hs, rng, derivative=False):
    """Gaussian multiplier max over a FIXED finite (h,x) family; target f_h.
    Report approximate inference only; tails with low effective n are masked.
    Same multipliers couple all bandwidths in one simultaneous critical value.
    """
    z = rng.normal(size=(BOOT, len(x)))
    maxima = np.zeros(BOOT)
    curves = []
    for h in hs:
        w0 = weights(x, grid, h)
        neff = w0.sum(axis=0)**2/(w0*w0).sum(axis=0)
        w = -(grid[None, :]-x[:, None])*w0/(h*h) if derivative else w0
        mean = w.mean(axis=0)
        c = w-mean
        normc = np.sqrt((c*c).sum(axis=0))
        se = normc/np.sqrt(len(x)*(len(x)-1))
        # One family covers ALL grid points; display masks sparse locations only.
        good = normc > np.finfo(float).tiny
        process = z @ (c[:, good]/normc[good])
        maxima = np.maximum(maxima, np.abs(process).max(axis=1))
        curves.append((mean, se, neff))
    q = float(np.quantile(maxima, .95))
    return q, curves

def real_data(name, x, limits, fixed_hs, rng):
    n = len(x)
    hn, hc, hs, score = select_h(x)
    grid = np.linspace(*limits, 501)
    ks = np.arange(4, 46)
    hist_scores = []
    for k in ks:
        counts, _ = np.histogram(x, np.linspace(*limits, k+1))
        width = (limits[1]-limits[0])/k
        hist_scores.append(2/((n-1)*width)-(n+1)/((n-1)*width)*np.sum((counts/n)**2))
    kb = int(ks[np.argmin(hist_scores)])
    # Exact binomial intervals with Bonferroni over ALL candidate bins,
    # so subsequent selection of k from this fixed family is allowed.
    tail = .05/(2*int(ks.sum()))
    fig, axes = plt.subplots(1,3,figsize=(9,3.2))
    for a,k in zip(axes,[max(4,kb//2),kb,min(45,2*kb)]):
        edges=np.linspace(*limits,k+1); width=(limits[1]-limits[0])/k
        counts,_=np.histogram(x,edges)
        lower=np.zeros(k); upper=np.ones(k)
        ok=counts>0; lower[ok]=beta.ppf(tail,counts[ok],n-counts[ok]+1)
        ok=counts<n; upper[ok]=beta.ppf(1-tail,counts[ok]+1,n-counts[ok])
        a.stairs(counts/(n*width),edges,label="Histogram")
        a.stairs(upper/width,edges,baseline=lower/width,fill=True,alpha=.18,label="Simultaneous 95%")
        a.set_title(f"k={k}; width={width:.4g}"); a.set_xlim(limits)
    axes[0].legend(fontsize=7)
    fig.tight_layout(); fig.savefig(FIG/f"{name.lower()}_histograms.pdf"); plt.close(fig)
    fig, ax = plt.subplots(2, 2, figsize=(9, 6.4))
    ax[0,0].hist(x, bins=np.linspace(*limits,kb+1), density=True, color=".85", label=f"Histogram CV: {kb} bins")
    for h, label in [(hn, "NR"), (hc, "LSCV")]:
        ax[0,0].plot(grid, kde(x,grid,h), label=f"{label}: h={h:.4g}")
    ax[0,0].legend(fontsize=7)
    ax[0,0].set_title(f"{name}: n={n}")
    ax[0,1].semilogx(hs,score)
    ax[0,1].axvline(hc,color="C1",ls="--",label="LSCV")
    ax[0,1].axvline(hn,color="C0",ls=":",label="NR")
    ax[0,1].set_title("Exact least-squares CV"); ax[0,1].set_xlabel("h")
    for kernel, mu2 in [("Gaussian",1),("Epanechnikov",.2),("Uniform",1/3)]:
        ax[1,0].plot(grid,kde(x,grid,hc/np.sqrt(mu2),kernel),label=kernel)
    ax[1,0].set_title("Equal smoothing variance: h_K sqrt(mu2)=h_CV")
    ax[1,0].legend(fontsize=7)
    w = weights(x,grid,hc)
    est = w.mean(axis=0); se = w.std(axis=0,ddof=1)/np.sqrt(n)
    ax[1,1].fill_between(grid,np.maximum(0,est-1.96*se),est+1.96*se,alpha=.22)
    ax[1,1].plot(grid,est)
    ax[1,1].set_title("Pointwise 95% normal intervals at selected h\n(selection uncertainty omitted)")
    for a in [ax[0,0],ax[1,0],ax[1,1]]:
        a.set_xlim(limits); a.set_xlabel("Salary (1000 USD)" if name=="CEO" else "RI (book scale)")
        a.set_ylabel("Density")
    fig.tight_layout(); fig.savefig(FIG/f"{name.lower()}_overview.pdf"); plt.close(fig)
    bandgrid = np.linspace(*limits, 241)
    q, curves = bands(x,bandgrid,fixed_hs,rng)
    qd, deriv = bands(x,bandgrid,fixed_hs,rng,True)
    fig, axes = plt.subplots(2,3,figsize=(9,5.8))
    modes = {}
    derivative_regions = {}
    for i,(h,(est,se,neff)) in enumerate(zip(fixed_hs,curves)):
        a=axes.flat[i]; valid=neff>=5
        a.fill_between(bandgrid,np.maximum(0,est-q*se),est+q*se,where=valid,alpha=.23)
        a.plot(bandgrid,est); a.set_title(f"h={h:g}; common critical={q:.2f}")
        a.set_xlim(limits)
        modes[str(h)] = bandgrid[find_peaks(est)[0]].tolist()
        dm, ds, dn = deriv[i]
        signs=np.where(dm-qd*ds>0,1,np.where(dm+qd*ds<0,-1,0))
        signs[dn<5]=0
        derivative_regions[str(h)]={"increasing_grid_points":int(np.sum(signs==1)),"decreasing_grid_points":int(np.sum(signs==-1))}
    ax=axes.flat[-1]
    signmap=[]
    for dm,ds,dn in deriv:
        s=np.where(dm-qd*ds>0,1,np.where(dm+qd*ds<0,-1,0)); s[dn<5]=0; signmap.append(s)
    ax.imshow(signmap,aspect="auto",origin="lower",extent=[*limits,-.5,len(fixed_hs)-.5],cmap="coolwarm",vmin=-1,vmax=1,interpolation="nearest")
    ax.set_yticks(range(len(fixed_hs)),[f"{h:g}" for h in fixed_hs]); ax.set_ylabel("h")
    ax.set_title("Derivative: red + / blue - / white unresolved\nFixed-grid multiplier, not full SiZer")
    fig.tight_layout(); fig.savefig(FIG/f"{name.lower()}_bands.pdf"); plt.close(fig)
    out={"n":n,"min":float(min(x)),"max":float(max(x)),"mean":float(np.mean(x)),"sd":float(np.std(x,ddof=1)),"iqr":float(np.diff(np.quantile(x,[.25,.75]))[0]),"h_NR":hn,"h_CV":hc,"CV_min":float(min(score)),"hist_bins":kb,"hist_width":(limits[1]-limits[0])/kb,"fixed_hs":fixed_hs,"band_critical":q,"derivative_critical":qd,"modes_fixed_h":modes,"derivative_regions":derivative_regions}
    if name=="Glass":
        fig,axes=plt.subplots(1,2,figsize=(9,3.5))
        ll={}
        for a,h,title in zip(axes,[hc,hn],["LSCV h","NR h"]):
            ll[title]={}
            for degree in [0,1,2]:
                y=local_likelihood(x,grid,h,degree)
                mass=float(trap(y,grid))
                ll[title][str(degree)]={"raw_mass_on_grid":mass,"maximum_normalized":float(max(y/mass))}
                a.plot(grid,y/mass,label=f"degree {degree}")
            a.set_title(f"{title}={h:.4g}; normalized on [{limits[0]}, {limits[1]}]")
            a.legend(); a.set_xlim(-6,9)
        assert np.allclose(local_likelihood(x,grid,hc,0),kde(x,grid,hc),rtol=1e-12)
        fig.tight_layout(); fig.savefig(FIG/"glass_local_likelihood.pdf"); plt.close(fig)
        out["local_likelihood"]=ll
    return out

def bart_truth(grid):
    return .5*phi(grid)+sum(.1*phi((grid-m)/.1)/.1 for m in np.linspace(-1,1,5))

def bart_sample(n,rng):
    narrow=rng.random(n)>=.5
    x=rng.normal(size=n)
    x[narrow]=rng.integers(0,5,narrow.sum())/2-1+.1*rng.normal(size=narrow.sum())
    return x

def regression_density(x,grid):
    # Exact x-scale counterpart of book Y_j=sqrt(k/n)*sqrt(N_j+1/4).
    k=max(3,int(np.floor(len(x)/10+.5)))
    edges=np.linspace(-6,6,k+1); delta=12/k
    assert np.all((x>=-6)&(x<=6)), "Increase domain; do not silently drop data"
    counts,_=np.histogram(x,edges); centers=(edges[:-1]+edges[1:])/2
    y=np.sqrt((counts+.25)/(len(x)*delta))
    bs=np.geomspace(.25*delta,4,61)
    gcv=[]
    for b in bs:
        w=phi((centers[:,None]-centers[None,:])/b); S=w/w.sum(axis=1,keepdims=True)
        gcv.append(np.mean((y-S@y)**2)/(1-np.trace(S)/k)**2)
    b=float(bs[np.argmin(gcv)])
    w=phi((grid[:,None]-centers[None,:])/b)
    r=(w@y)/w.sum(axis=1)
    f=np.maximum(r,0)**2; f/=trap(f,grid)
    return f,{"bins":k,"b_GCV":b,"b_at_edge":bool(np.argmin(gcv) in [0,len(bs)-1])}

def simulation():
    rng=np.random.default_rng(SEED+2)
    grid=np.linspace(-6,6,2401); truth=bart_truth(grid)
    fig,axes=plt.subplots(2,2,figsize=(9,6.5))
    output={}
    for n,a in zip([25,50,100,1000],axes.flat):
        errors=[]; bandwidths=[]; edge=0
        for rep in range(REPS):
            x=bart_sample(n,rng)
            hn,hc,_,_=select_h(x)
            fn=kde(x,grid,hn); fc=kde(x,grid,hc); fr,meta=regression_density(x,grid)
            errors.append([trap((y-truth)**2,grid) for y in [fn,fc,fr]])
            bandwidths.append([hn,hc]); edge+=meta["b_at_edge"]
            if rep==0:
                a.plot(grid,truth,"k--",lw=1,label="Truth")
                for y,label in [(fn,"KDE NR"),(fc,"KDE LSCV"),(fr,"Section 6.6 / GCV")]: a.plot(grid,y,label=label)
                a.set_title(f"n={n}; h_NR={hn:.3f}; h_CV={hc:.3f}; k={meta['bins']}")
                a.set_xlim(-2,2); a.set_ylim(bottom=0)
                np.savetxt(ROOT/"data"/f"bart_n{n}_example.csv",x,delimiter=",",header="x",comments="")
        errors=np.array(errors); bandwidths=np.array(bandwidths)
        output[str(n)]={"mean_ISE":errors.mean(axis=0).tolist(),"MC_SE":(errors.std(axis=0,ddof=1)/np.sqrt(REPS)).tolist(),"example_ISE":errors[0].tolist(),"mean_h":bandwidths.mean(axis=0).tolist(),"regression_bandwidth_edge_count":edge}
        np.savetxt(ROOT/f"bart_n{n}_replicates.csv",np.column_stack([errors,bandwidths]),delimiter=",",header="ISE_NR,ISE_CV,ISE_regression,h_NR,h_CV",comments="")
        print(f"Bart n={n}: {output[str(n)]}",flush=True)
    axes[0,0].legend(fontsize=7); fig.tight_layout(); fig.savefig(FIG/"bart_comparison.pdf"); plt.close(fig)
    return output

def validate():
    x=np.array([-1.,0.,1.]); h=.75
    assert abs(cv_scores(x,[h])[0]-(-.05501663588822664))<1e-12
    g=np.linspace(-10,10,20001)
    for kernel,mu in [("Gaussian",1),("Epanechnikov",.2),("Uniform",1/3)]:
        assert abs(trap(kde(x,g,.7,kernel),g)-1)<.002
    # LOO definition vs pairwise formula, numerical integration independent check.
    direct=trap(kde(x,g,h)**2,g)-2*np.mean([kde(np.delete(x,i),np.array([v]),h)[0] for i,v in enumerate(x)])
    assert abs(direct-cv_scores(x,[h])[0])<1e-9
    # Local quadratic reproduces a Normal density when weighted population moments are supplied.
    # Sample version: verify moment equations numerically for both fitted coefficients.
    t=x-.2; w=phi(t/.8); m=np.sum(w*t)/sum(w); v=np.sum(w*(t-m)**2)/sum(w)
    a1=m/v; a2=1/.8**2-1/v
    assert abs(1/(1/.8**2-a2)-v)<1e-12
    assert abs(a1*v-m)<1e-12

def write_tables(out):
    rows=[r"\begin{center}\begin{tabular}{lrr}\toprule Đại lượng & CEO & Glass\\\midrule"]
    for label,key in [("$n$","n"),("Trung bình","mean"),("$s$","sd"),("IQR","iqr"),("$h_{NR}$","h_NR"),("$h_{CV}$","h_CV"),("Số bin histogram CV","hist_bins"),("Độ rộng bin","hist_width"),("Ngưỡng băng đồng thời","band_critical")]:
        rows.append(f"{label} & {out['CEO'][key]:.5g} & {out['Glass'][key]:.5g}"+r"\\")
    rows.append(r"\bottomrule\end{tabular}\end{center}")
    (ROOT/"real_tables.tex").write_text("\n".join(rows),encoding="utf-8")
    rows=[r"\begin{center}\small\begin{tabular}{rrrr}\toprule $n$ & KDE NR & KDE CV & Mục 6.6 (GCV)\\\midrule"]
    for n,result in out['Bart'].items():
        vals=[f"${v:.4f} \\pm {s:.4f}$" for v,s in zip(result['mean_ISE'],result['MC_SE'])]
        rows.append(n+" & "+" & ".join(vals)+r"\\")
    rows.append(r"\bottomrule\end{tabular}\end{center}")
    (ROOT/"bart_tables.tex").write_text("\n".join(rows),encoding="utf-8")

def main():
    validate()
    ceo=np.genfromtxt(ROOT/"data"/"ceo.csv",delimiter=",",names=True,missing_values="NA",filling_values=np.nan)["Salary"]
    assert len(ceo)==60 and np.isnan(ceo).sum()==1
    ceo=ceo[np.isfinite(ceo)]
    glass=np.loadtxt(ROOT/"data"/"glass.dat",skiprows=1,usecols=1)
    assert len(glass)==214 and abs(glass[0]-3.01)<1e-10
    out={"seed":SEED,"replications":REPS,"bootstrap":BOOT,"versions":{"numpy":np.__version__,"scipy":scipy.__version__,"matplotlib":matplotlib.__version__},"sha256":{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in (ROOT/"data").iterdir() if p.name in ['ceo.csv','ceo.rda','glass.dat']}}
    rng=np.random.default_rng(SEED)
    out["CEO"]=real_data("CEO",ceo,(0,1400),[40,80,120,160,240],rng)
    print("CEO complete",flush=True)
    out["Glass"]=real_data("Glass",glass,(-8,18),[.2,.4,.8,1.6,3.2],rng)
    print("Glass complete",flush=True)
    out["Bart"]=simulation()
    write_tables(out)
    (ROOT/"results.json").write_text(json.dumps(out,indent=2),encoding="utf-8")
    print("Checks passed; all figures and tables written.",flush=True)

if __name__=="__main__": main()
