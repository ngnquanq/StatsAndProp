"""Reproduce numerical checks and monochrome figures for the LaTeX guide.

Run from any directory with Python 3, numpy, scipy, sympy and matplotlib:
    /opt/anaconda3/bin/python verify_and_figures.py
Only writes figures/ and verification.json beside this script.
"""
from pathlib import Path
import json
import math
import os
import shutil
import subprocess

ROOT = Path(__file__).resolve().parent
os.environ.setdefault("MPLCONFIGDIR", str(ROOT / ".cache" / "matplotlib"))
os.environ.setdefault("XDG_CACHE_HOME", str(ROOT / ".cache"))

import numpy as np
import sympy as sp
from scipy.integrate import quad
from scipy.stats import norm, kstest, cramervonmises
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib import font_manager

FIGURES = ROOT / "figures"
REPORT = {}
checks = 0


def close(actual, expected, label, atol=1e-10, rtol=1e-8):
    global checks
    if not math.isclose(float(actual), float(expected), abs_tol=atol, rel_tol=rtol):
        raise AssertionError(f"{label}: {actual} != {expected}")
    checks += 1


def check(condition, label):
    global checks
    if not condition:
        raise AssertionError(label)
    checks += 1


def phi(u):
    return norm.pdf(u)


KERNELS = {
    "Gaussian": phi,
    "Epanechnikov": lambda u: .75 * np.maximum(1 - np.asarray(u)**2, 0),
    "Uniform": lambda u: .5 * (np.abs(u) <= 1),
    "Triangular": lambda u: np.maximum(1 - np.abs(u), 0),
    "Biweight": lambda u: 15/16 * np.maximum(1 - np.asarray(u)**2, 0)**2,
    "Triweight": lambda u: 35/32 * np.maximum(1 - np.asarray(u)**2, 0)**3,
    "Tricube": lambda u: 70/81 * np.maximum(1 - np.abs(u)**3, 0)**3,
}


def kde(x, h, data, kernel=phi):
    check(h > 0, "positive bandwidth")
    return np.mean(kernel((np.asarray(x)[..., None] - data)/h), axis=-1)/h


def derivatives(x, h, data, kind):
    u = (x - data)/h
    if kind == "Gaussian":
        k1, k2 = -u*phi(u), (u*u - 1)*phi(u)
    elif kind == "Biweight":
        check(not np.any(np.abs(u) == 1), "biweight second derivative away from knots")
        k1 = np.where(np.abs(u) < 1, -15/4*u*(1-u*u), 0)
        k2 = np.where(np.abs(u) < 1, 15/4*(3*u*u-1), 0)
    elif kind == "Epanechnikov":
        check(not np.any(np.abs(u) == 1), "Epanechnikov derivatives away from knots")
        k1 = np.where(np.abs(u) < 1, -1.5*u, 0)
        k2 = np.where(np.abs(u) < 1, -1.5, 0)
    else:
        check(not np.any(np.abs(u) == 1), "compact derivatives away from endpoint knots")
        if kind == "Triangular":
            check(not np.any(u == 0), "triangular derivative away from zero")
            k1 = np.where(np.abs(u) < 1, -np.sign(u), 0)
        else:
            k1 = np.zeros_like(u)
        k2 = np.zeros_like(u)
    return float(np.mean(k1)/h**2), float(np.mean(k2)/h**3)


def gaussian_cv(h, data):
    n = len(data)
    u = (data[:, None] - data[None, :])/h
    integral = np.sum(np.exp(-u*u/4)/(2*math.sqrt(math.pi)))/(n*n*h)
    loo = np.sum(phi(u)[~np.eye(n, dtype=bool)])/((n-1)*h)
    return float(integral - 2*loo/n), float(integral), float(loo)


def ks_parts(data, cdf):
    x = np.sort(data)
    n = len(x)
    u = cdf(x)
    plus = np.max(np.arange(1, n+1)/n-u)
    minus = np.max(u-np.arange(n)/n)
    return float(plus), float(minus), float(max(plus, minus))


def smooth(xgrid, data, responses, h):
    nw, ll = [], []
    for x in xgrid:
        d = data-x
        k = KERNELS["Epanechnikov"](d/h)
        s0, s1, s2 = (np.sum(k*d**q) for q in range(3))
        delta = s0*s2-s1*s1
        check(s0 > 0 and delta > 1e-14, "supported local regression design")
        w = k*(s2-s1*d)/delta
        close(np.sum(w), 1, "LL unit moment")
        close(np.dot(w, d), 0, "LL first moment", atol=1e-12)
        nw.append(np.dot(k, responses)/s0)
        ll.append(np.dot(w, responses))
    return np.asarray(nw), np.asarray(ll)


def verify():
    u = sp.symbols("u", real=True)
    expressions = {
        "Epanechnikov": sp.Rational(3,4)*(1-u*u),
        "Uniform": sp.Rational(1,2),
        "Triangular": 1-u,
        "Biweight": sp.Rational(15,16)*(1-u*u)**2,
        "Triweight": sp.Rational(35,32)*(1-u*u)**3,
        "Tricube": sp.Rational(70,81)*(1-u**3)**3,
    }
    expected = {
        "Epanechnikov": (sp.Rational(1,5), sp.Rational(3,5)),
        "Uniform": (sp.Rational(1,3), sp.Rational(1,2)),
        "Triangular": (sp.Rational(1,6), sp.Rational(2,3)),
        "Biweight": (sp.Rational(1,7), sp.Rational(5,7)),
        "Triweight": (sp.Rational(1,9), sp.Rational(350,429)),
        "Tricube": (sp.Rational(35,243), sp.Rational(175,247)),
    }
    kernel_report = {}
    for name, expression in expressions.items():
        mass = 2*sp.integrate(expression, (u, 0, 1))
        mu2 = 2*sp.integrate(u*u*expression, (u, 0, 1))
        rk = 2*sp.integrate(expression**2, (u, 0, 1))
        check(mass == 1, f"symbolic mass {name}")
        check((mu2, rk) == expected[name], f"symbolic moments {name}")
        fn = KERNELS[name]
        close(quad(lambda z: float(fn(z)), -1, 1, points=[0])[0], 1, f"quadrature mass {name}")
        close(quad(lambda z: z*z*float(fn(z)), -1, 1, points=[0])[0], mu2, f"quadrature mu2 {name}")
        close(quad(lambda z: float(fn(z))**2, -1, 1, points=[0])[0], rk, f"quadrature R {name}")
        kernel_report[name] = {"mu2_exact": str(mu2), "R_exact": str(rk)}
    close(quad(lambda z: z*z*phi(z), -np.inf, np.inf)[0], 1, "Gaussian mu2")
    close(quad(lambda z: phi(z)**2, -np.inf, np.inf)[0], 1/(2*math.sqrt(math.pi)), "Gaussian R")
    REPORT["kernel_moments"] = kernel_report

    # Differentiate the stated interior expressions independently with SymPy.
    stated = {
        "Epanechnikov": (-sp.Rational(3,2)*u, -sp.Rational(3,2)),
        "Uniform": (0, 0), "Triangular": (-1, 0),
        "Biweight": (-sp.Rational(15,4)*u*(1-u*u), sp.Rational(15,4)*(3*u*u-1)),
        "Triweight": (-sp.Rational(105,16)*u*(1-u*u)**2, -sp.Rational(105,16)*(1-u*u)*(1-5*u*u)),
        "Tricube": (-sp.Rational(70,9)*u*u*(1-u**3)**2, -sp.Rational(140,9)*u*(1-u**3)*(1-4*u**3)),
    }
    for name, expression in expressions.items():
        for q in (1, 2):
            check(sp.simplify(sp.diff(expression, u, q)-stated[name][q-1]) == 0, f"symbolic derivative {name} order {q}")
    gaussian = sp.exp(-u*u/2)/sp.sqrt(2*sp.pi)
    check(sp.simplify(sp.diff(gaussian,u)+u*gaussian) == 0, "Gaussian first derivative")
    check(sp.simplify(sp.diff(gaussian,u,2)-(u*u-1)*gaussian) == 0, "Gaussian second derivative")
    REPORT["derivative_table"] = "All seven interior derivative formulas verified symbolically; knots checked separately."

    data = np.array([1.,2.,4.,5.])
    density = {}
    for name in ("Epanechnikov", "Uniform", "Triangular", "Gaussian"):
        value = float(kde(3, 2, data, KERNELS[name]))
        density[name] = value
    close(density["Epanechnikov"], 9/64, "original Epanechnikov KDE")
    close(density["Uniform"], 1/4, "closed-endpoint Uniform KDE")
    close(density["Triangular"], 1/8, "original triangular KDE")
    close(density["Gaussian"], (phi(1)+phi(.5))/4, "original Gaussian KDE")
    dg = derivatives(3, 2, data, "Gaussian")
    close(dg[0], 0, "Gaussian symmetric first derivative")
    close(dg[1], -3*phi(.5)/64, "Gaussian original second derivative")
    # Test the WHOLE KDE near the shared knots rather than differentiating a.e.
    delta = 1e-6
    for name, slope in [("Epanechnikov", 3/32), ("Triangular", 1/16)]:
        k = KERNELS[name]
        mid = kde(3, 2, data, k)
        left = (mid-kde(3-delta,2,data,k))/delta
        right = (kde(3+delta,2,data,k)-mid)/delta
        close(left, -slope, f"left cusp slope {name}", atol=1e-6)
        close(right, slope, f"right cusp slope {name}", atol=1e-6)
        check(left < 0 < right, f"derivative does not exist {name}")
    close(kde(3-delta,2,data,KERNELS["Uniform"]), 3/16, "Uniform left limit")
    close(kde(3+delta,2,data,KERNELS["Uniform"]), 3/16, "Uniform right limit")
    check(density["Uniform"] != 3/16, "Uniform discontinuity at evaluation point")
    density["Gaussian_derivatives"] = dg
    density["at_h_1.5"] = {}
    for name, target in [("Epanechnikov",5/36),("Uniform",1/6),("Triangular",1/9),("Gaussian",(phi(4/3)+phi(2/3))/3)]:
        close(kde(3,1.5,data,KERNELS[name]), target, f"smooth-point value {name}")
        dd = derivatives(3,1.5,data,name)
        close(dd[0],0,f"smooth-point first derivative {name}")
        density["at_h_1.5"][name] = {"density":float(target), "d1":dd[0], "d2":dd[1]}
    close(density["at_h_1.5"]["Epanechnikov"]["d2"], -2/9, "smooth Epanechnikov curvature")
    bi_data = np.array([0.,1.,2.])
    close(kde(1,2,bi_data,KERNELS["Biweight"]),85/256,"Biweight density exercise")
    db = derivatives(1,2,bi_data,"Biweight")
    close(db[0],0,"Biweight d1 exercise"); close(db[1],-15/64,"Biweight d2 exercise")
    REPORT["density_exercises"] = density

    sd = math.sqrt(10/3)
    coefficient = (4/3)**.2
    REPORT["normal_reference"] = {"sample_s":sd, "coefficient":coefficient,
                                  "h_exact":coefficient*sd*4**(-.2),
                                  "h_rounded_1.06":1.06*sd*4**(-.2)}
    close(coefficient,1.0592238410488122,"NR coefficient")
    rf2 = quad(lambda x: ((x*x-1)*phi(x))**2,-np.inf,np.inf)[0]
    close(rf2,3/(8*math.sqrt(math.pi)),"normal integrated squared second derivative")
    hopt = coefficient*100**(-.2)
    amise = lambda h: rf2*h**4/4+1/(2*math.sqrt(math.pi)*100*h)
    check(amise(hopt) < amise(.8*hopt) and amise(hopt) < amise(1.2*hopt),"AMISE minimum")
    for c in [.5,2]: close(amise(c*hopt)/amise(hopt),(c**4+4/c)/5,"AMISE ratio")
    k4 = (3-u*u)*gaussian/2
    for j, v in [(0,1),(1,0),(2,0),(3,0),(4,-3)]:
        check(sp.integrate(u**j*k4,(u,-sp.oo,sp.oo)) == v,f"fourth-order kernel moment {j}")

    hist_data = np.array([.1,.2,.4,.8])
    histogram = {}
    for m,want in [(2,-.75),(4,1/6)]:
        n = len(hist_data); h = 1/m
        counts,_ = np.histogram(hist_data,bins=np.linspace(0,1,m+1))
        ps = counts/n
        cv = 2/((n-1)*h)-(n+1)*np.sum(ps*ps)/((n-1)*h)
        integrated = np.sum(ps*ps)/h
        indices = np.minimum((hist_data*m).astype(int),m-1)
        loo = np.sum((counts[indices]-1)/((n-1)*h))
        close(cv,integrated-2*loo/n,"histogram CV independent form")
        close(cv,want,"histogram CV exercise")
        close(np.sum(ps/h)*h,1,"histogram mass")
        ahat = np.sqrt(m)*ps
        check(np.allclose(ahat*np.sqrt(m),ps/h),"histogram equals projection")
        histogram[str(m)] = {"counts":counts.tolist(), "CV":float(cv)}
    h=.25; n=96
    probs = np.array([1,3,5,7])/16
    hist_var = (1-np.sum(probs**2))/(n*h)
    exact_bias = sum(quad(lambda x,j=j: (probs[j]/h-2*x)**2,j*h,(j+1)*h)[0] for j in range(4))
    close(exact_bias,1/48,"linear-density exact histogram bias")
    close(hist_var,43/1536,"linear-density histogram variance")
    close(exact_bias+hist_var,25/512,"linear-density exact histogram MISE")
    REPORT["histogram"] = histogram

    cv_data = np.array([0.,1.,2.]); n=3
    distances=np.abs(cv_data[:,None]-cv_data[None,:])
    cv_report={}
    for h,want in [(.75,26/81),(1.5,-17/81)]:
        integral=np.maximum(2*h-distances,0).sum()/(4*n*n*h*h)
        loo=(.5*(distances<=h))[~np.eye(n,dtype=bool)].sum()/((n-1)*h)
        cv=integral-2*loo/n
        edges=np.unique(np.r_[cv_data-h,cv_data+h])
        direct=sum(quad(lambda x:float(kde(x,h,cv_data,KERNELS["Uniform"]))**2,a,b)[0] for a,b in zip(edges[:-1],edges[1:]))
        close(direct,integral,"Uniform squared KDE integral")
        close(cv,want,"Uniform CV exercise")
        cv_report[str(h)]={"integrated_square":float(integral),"loo_sum":float(loo),"CV":float(cv)}
    gaussian_data=np.array([0.,1.])
    for h in [.5,1.]:
        score,integral,loo=gaussian_cv(h,gaussian_data)
        direct=quad(lambda x:float(kde(x,h,gaussian_data))**2,-np.inf,np.inf)[0]
        direct_loo=2*phi(1/h)/h
        close(integral,direct,"Gaussian squared integral")
        close(loo,direct_loo,"Gaussian direct leave-one-out")
        cv_report[f"Gaussian_h={h}"]={"integrated_square":integral,"loo_sum":loo,"CV":score}
    check(cv_report["Gaussian_h=1.0"]["CV"] < cv_report["Gaussian_h=0.5"]["CV"],"Gaussian CV selection")
    REPORT["CV"] = cv_report

    ks_report={}
    for name,data,cdf in [
        ("uniform",np.array([.1,.4,.6,.8]),lambda x:x),
        ("exponential",np.array([.2,.5,1.,1.5]),lambda x:-np.expm1(-x)),
        ("ties",np.array([.2,.2,.7,.9]),lambda x:x),
    ]:
        plus,minus,dn=ks_parts(data,cdf)
        close(dn,kstest(data,cdf).statistic,f"KS SciPy comparison {name}")
        ks_report[name]={"Dplus":plus,"Dminus":minus,"D":dn,"u":cdf(np.sort(data)).tolist()}
        if name=="uniform":
            n=len(data); ui=np.sort(data)
            cvm=1/(12*n)+np.sum((ui-(2*np.arange(1,n+1)-1)/(2*n))**2)
            close(cvm,cramervonmises(data,cdf).statistic,"CvM reference algorithm")
            endpoints=np.r_[0,ui,1]
            direct=sum(n*quad(lambda t,i=i:(i/n-t)**2,endpoints[i],endpoints[i+1])[0] for i in range(n+1))
            close(cvm,direct,"CvM direct integral")
            ad=-n-np.sum((2*np.arange(1,n+1)-1)*(np.log(ui)+np.log1p(-ui[::-1])))/n
            direct_ad=sum(n*quad(lambda t,i=i:(i/n-t)**2/(t*(1-t)),endpoints[i],endpoints[i+1])[0] for i in range(n+1))
            close(ad,direct_ad,"AD direct integral")
            ks_report[name]["CvM"]=float(cvm); ks_report[name]["AD"]=float(ad)
    close(ks_report["uniform"]["D"],.2,"Uniform KS exercise answer")
    close(ks_report["ties"]["D"],.3,"Tied KS exercise answer")
    eps=math.sqrt(math.log(40)/200)
    close(eps,.13581015157406195,"DKW n100")
    check(math.ceil(math.log(40)/(2*.05**2)) == 738,"DKW sample size")
    REPORT["KS_CvM_AD"] = ks_report

    # EDF covariance: enumerate a three-region Bernoulli pair exactly.
    p,q=.2,.7
    exy=p; covariance=(exy-p*q)/100
    close(covariance,.0006,"EDF covariance")
    v=np.array([1.,2.,4.,5.])
    close(np.mean((v-v.mean())**2),2.5,"plug-in variance")
    close(np.var(v,ddof=1),10/3,"unbiased sample variance")
    close(np.mean((v-v.mean())**3),0,"sample skewness numerator")
    # Boundary formulas independently integrated.
    h=.2
    original=(1-math.exp(-h))/(2*h)
    reflected=(1-math.exp(-h))/h
    close(quad(lambda t:.5*math.exp(-t)/h,0,h)[0],original,"exponential boundary integral")
    close(reflected,2*original,"reflection at zero")
    check(sp.integrate(4-6*u,(u,0,1))==1,"boundary kernel mass")
    check(sp.integrate(u*(4-6*u),(u,0,1))==0,"boundary kernel first moment")
    check(sp.integrate(u*u*(4-6*u),(u,0,1))==-sp.Rational(1,6),"boundary kernel second moment")
    REPORT["boundary"]={"h":h,"original_expectation":original,"reflected_expectation":reflected}
    # Projection coefficients and contrast are verified by direct quadrature.
    projection=lambda x:1+math.cos(2*math.pi*x)+math.sin(2*math.pi*x)
    close(quad(projection,0,1)[0],1,"trig projection mass")
    close(quad(lambda x:projection(x)**2,0,1)[0],2,"trig projection norm")
    close(projection(5/8),1-math.sqrt(2),"negative projection value")
    # Beginner projection example: check bin counts, contrasts, selected model,
    # and Pythagoras against independent integrals rather than trusting the table.
    beginner_data = np.array([.10,.12,.20,.30,.40,.60,.80,.90])
    model_report = {}
    for dimension, wanted_counts, wanted_norm, wanted_score in [
        (1,[8],1,-23/24), (2,[5,3],17/16,-47/48), (4,[3,2,1,2],9/8,-23/24),
    ]:
        counts, edges = np.histogram(beginner_data,bins=np.linspace(0,1,dimension+1))
        check(counts.tolist() == wanted_counts,"beginner projection bin counts")
        heights = dimension*counts/len(beginner_data)
        norm_squared = np.sum(heights**2)/dimension
        close(norm_squared,wanted_norm,"beginner projection squared norm")
        values_at_data = heights[np.minimum((beginner_data*dimension).astype(int),dimension-1)]
        contrast = norm_squared-2*np.mean(values_at_data)
        close(contrast,-norm_squared,"beginner contrast evaluated at observations")
        score = contrast+dimension/24
        close(score,wanted_score,"beginner penalized model score")
        model_report[str(dimension)] = {"counts":counts.tolist(),"heights":heights.tolist(),
                                       "contrast":float(contrast),"score":float(score)}
    check(min(model_report,key=lambda d:model_report[d]["score"]) == "2","beginner selected model")
    approximation_error = quad(lambda x:(2*x-.5)**2,0,.5)[0]+quad(lambda x:(2*x-1.5)**2,.5,1)[0]
    estimation_error = .5*((1.25-.5)**2+(.75-1.5)**2)
    total_error = quad(lambda x:(2*x-1.25)**2,0,.5)[0]+quad(lambda x:(2*x-.75)**2,.5,1)[0]
    close(approximation_error,1/12,"beginner approximation error")
    close(estimation_error,9/16,"beginner estimation error")
    close(total_error,31/48,"beginner total error")
    close(total_error,approximation_error+estimation_error,"beginner Pythagoras independent integration")
    REPORT["beginner_projection"] = model_report
    n=40;k=4;counts=np.array([4,8,12,16])
    squared=k/n*(counts+.25); normalizer=squared.mean()
    close(normalizer,1.025,"root-unroot normalizer")
    check(np.allclose(squared/normalizer,np.array([17,33,49,65])/41),"root-unroot heights")
    close((k/(4*n)),.025,"root-unroot variance")
    REPORT["root_unroot"]={"Y":np.sqrt(squared).tolist(),"normalizer":float(normalizer)}


def save(fig, name):
    fig.savefig(FIGURES/name, bbox_inches="tight", metadata={"Author":"", "Title":name})
    plt.close(fig)


def figures():
    FIGURES.mkdir(exist_ok=True)
    family = "serif"
    if shutil.which("kpsewhich"):
        font_path = subprocess.run(["kpsewhich", "lmroman10-regular.otf"],
                                   check=True, capture_output=True, text=True).stdout.strip()
        if font_path:
            font_manager.fontManager.addfont(font_path)
            family = font_manager.FontProperties(fname=font_path).get_name()
    plt.rcParams.update({"font.family":family, "mathtext.fontset":"cm", "font.size":10,
                         "axes.spines.top":False,"axes.spines.right":False,
                         "axes.grid":True,"grid.color":"0.85","grid.linewidth":.4})
    rng=np.random.default_rng(20261009)
    styles=["-","--","-.",":",(0,(5,1,1,1)),(0,(3,1,1,1,1,1)),(0,(1,1))]
    sample=np.sort(rng.normal(size=100))
    x=np.linspace(-3.5,3.5,1000)
    ecdf=np.searchsorted(sample,x,side="right")/len(sample)
    eps=math.sqrt(math.log(40)/(2*len(sample)))
    fig,ax=plt.subplots(figsize=(7.4,3.8))
    ax.fill_between(x,np.maximum(0,ecdf-eps),np.minimum(1,ecdf+eps),step="post",color=".87",label="DKW 95%")
    ax.step(x,ecdf,where="post",color="black",lw=1,label="EDF")
    ax.plot(x,norm.cdf(x),"--",color="black",label="True CDF")
    ax.set(xlabel="$x$",ylabel="CDF",ylim=(-.02,1.02));ax.legend()
    save(fig,"edf_dkw.pdf")

    mixture=np.r_[rng.normal(-1,.45,100),rng.normal(1,.4,100)]
    x=np.linspace(-3,3,700)
    true=.5*norm.pdf(x,-1,.45)+.5*norm.pdf(x,1,.4)
    fig,axs=plt.subplots(1,2,figsize=(9,3.5),sharey=True)
    for ax,origin in zip(axs,[0,.3]):
        edges=np.arange(-3+origin,3.7,.6)
        ax.hist(mixture,bins=edges,density=True,facecolor=".9",edgecolor="black",linewidth=.7)
        ax.plot(x,true,color="black",label="True density")
        ax.set(title=f"Bin width = 0.6; origin shift = {origin}",xlabel="$x$")
    axs[0].set_ylabel("Density");axs[0].legend(fontsize=9)
    save(fig,"hist_origin.pdf")

    fig,ax=plt.subplots(figsize=(8,4.2));u=np.linspace(-2,2,1601)
    for i,(name,kernel) in enumerate(KERNELS.items()):
        ax.plot(u,kernel(u),color="black",ls=styles[i],lw=1.3,label=name)
    ax.set(xlabel="$u$",ylabel="$K(u)$");ax.legend(ncol=2,fontsize=9)
    save(fig,"kernels.pdf")

    fig,axs=plt.subplots(1,2,figsize=(9.5,3.9))
    x=np.linspace(-3,3,800)
    for i,h in enumerate([.12,.4,.9]):
        axs[0].plot(x,kde(x,h,mixture),color="black",ls=styles[i],label=f"$h={h}$")
    axs[0].set(xlabel="$x$",ylabel="Density",title="Gaussian KDE: same sample");axs[0].legend()
    h=np.linspace(.12,1,500);rf2=3/(8*math.sqrt(math.pi));rk=1/(2*math.sqrt(math.pi))
    b=rf2*h**4/4;v=rk/(100*h);hopt=(4/3)**.2*100**(-.2)
    for arr,style,label in [(b,"--","Integrated squared bias"),(v,":","Integrated variance"),(b+v,"-","AMISE")]:
        axs[1].plot(h,arr,color="black",ls=style,label=label)
    axs[1].axvline(hopt,color=".4",ls="-.",label=f"$h_*={hopt:.3f}$")
    axs[1].set(xlabel="$h$",ylabel="Approximate risk",title="Normal reference, $n=100$");axs[1].legend(fontsize=8)
    save(fig,"bandwidth_risk.pdf")

    x=np.linspace(0,1.2,600);h=.2
    expectation=(np.exp(-np.maximum(0,x-h))-np.exp(-(x+h)))/(2*h)
    reflection=expectation+np.where(x<h,(1-np.exp(-np.maximum(0,h-x)))/(2*h),0)
    fig,ax=plt.subplots(figsize=(7.5,3.8))
    ax.plot(x,np.exp(-x),color="black",label="True density")
    ax.plot(x,expectation,color="black",ls="--",label="Expected ordinary KDE")
    ax.plot(x,reflection,color="black",ls=":",label="Expected reflected KDE")
    ax.set(xlabel="$x$",ylabel="Density / expectation",title="Exponential density; Uniform kernel; $h=0.2$");ax.legend()
    save(fig,"boundary.pdf")

    design=np.linspace(0,1,240)**1.7
    response=1+2*design;x=np.linspace(0,1,151)
    nw,ll=smooth(x,design,response,.18)
    check(np.allclose(ll,1+2*x,atol=1e-11),"LL reproduces linear function including boundaries")
    fig,axs=plt.subplots(1,2,figsize=(9.5,3.7))
    for ax in axs:
        ax.plot(x,1+2*x,color=".5",lw=3,label="True linear function")
        ax.plot(x,nw,color="black",ls="--",label="Nadaraya-Watson")
        ax.plot(x,ll,color="black",ls=":",lw=1.5,label="Local linear")
        ax.set(xlabel="$x$",ylabel="Conditional mean")
    axs[0].set_title("Uneven design; full domain")
    axs[1].set(xlim=(0,.22),ylim=(1,1.55),title="Left boundary (zoom)")
    axs[0].legend(fontsize=8)
    save(fig,"regression.pdf")

    beginner_data = np.array([.10,.12,.20,.30,.40,.60,.80,.90])
    fig,axs=plt.subplots(1,3,figsize=(10,3.3),sharey=True)
    for ax,dimension in zip(axs,[1,2,4]):
        edges=np.linspace(0,1,dimension+1)
        counts,_=np.histogram(beginner_data,bins=edges)
        heights=dimension*counts/len(beginner_data)
        ax.stairs(heights,edges,fill=True,facecolor=".90",edgecolor="black",linewidth=1.2)
        ax.plot(beginner_data,np.full_like(beginner_data,-.06),"|",color="black",ms=8)
        ax.set(title=f"$D={dimension}$",xlabel="$x$",xlim=(-.025,1.025),ylim=(-.12,1.8))
        for center,height in zip((edges[:-1]+edges[1:])/2,heights):
            ax.text(center,height+.06,f"{height:g}",ha="center",fontsize=9)
    axs[0].set_ylabel("Density height")
    fig.tight_layout()
    save(fig,"projection_models.pdf")


if __name__ == "__main__":
    verify()
    figures()
    REPORT["checks_passed"] = checks
    REPORT["seed"] = 20261009
    REPORT["figures"] = sorted(p.name for p in FIGURES.glob("*.pdf"))
    (ROOT/"verification.json").write_text(json.dumps(REPORT,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print(f"Passed {checks} checks; generated {len(REPORT['figures'])} figures.")
    print(json.dumps({k:REPORT[k] for k in ["normal_reference","CV","KS_CvM_AD","density_exercises"]},indent=2))
