"""Numerical checks and figure generation for test_loi_giai_mo_rong.tex.
Run with Python with numpy, scipy, matplotlib installed.
"""
from pathlib import Path
import json
import math
import numpy as np
from scipy.integrate import quad
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parent
sqrtpi = math.sqrt(math.pi)
phi = lambda u: np.exp(-np.asarray(u)**2/2) / math.sqrt(2*math.pi)
kernels = {
    'Uniform': lambda u: 0.5*(np.abs(u) <= 1),
    'Triangular': lambda u: np.maximum(1-np.abs(u), 0),
    'Epanechnikov': lambda u: 0.75*np.maximum(1-np.asarray(u)**2, 0),
    'Gaussian': phi,
}
expected = {'Uniform': (1/3,1/2), 'Triangular': (1/6,2/3),
            'Epanechnikov': (1/5,3/5), 'Gaussian': (1,1/(2*sqrtpi))}
xdata = np.array([1.,2.,4.,5.])
def kde(x, h, kernel, data=xdata):
    x = np.asarray(x)
    return np.mean(kernel((x[...,None]-data)/h),axis=-1)/h

def close(a,b):
    assert math.isclose(a,b,rel_tol=1e-8,abs_tol=1e-10), (a,b)

report={}
for name,k in kernels.items():
    bound = np.inf if name=='Gaussian' else 1
    mass = quad(lambda u: float(k(u)),-bound,bound)[0]
    mu2 = quad(lambda u: u*u*float(k(u)),-bound,bound)[0]
    rk = quad(lambda u: float(k(u))**2,-bound,bound)[0]
    close(mass,1);close(mu2,expected[name][0]);close(rk,expected[name][1])
    points = {f'x={x},h={h}':float(kde(x,h,k)) for x in [1.5,4.5] for h in [1,1.5]}
    for h in [1,1.5]:close(kde(1.5,h,k),kde(4.5,h,k))
    rf2=3/(8*sqrtpi)
    coeff=(8*sqrtpi*rk/(3*mu2**2))**.2
    hopt=coeff*100**(-.2)
    amise=lambda h:mu2**2*rf2*h**4/4+rk/(100*h)
    close(rk/(100*hopt),mu2**2*rf2*hopt**4)
    assert amise(hopt)<amise(hopt*.9) and amise(hopt)<amise(hopt*1.1)
    report[name]={'mu2':mu2,'R':rk,'kde_original':float(kde(3,2,k)),
                  'windows':points,'normal_coefficient':coeff,
                  'amise_hopt_n100_sigma1':hopt,'amise_min':amise(hopt)}

close(kde(3,2,kernels['Uniform']),1/4)
close(kde(3,2,kernels['Triangular']),1/8)
close(kde(3,2,kernels['Epanechnikov']),9/64)
close(kde(1.5,1,kernels['Epanechnikov']),9/32)
close(kde(1.5,1.5,kernels['Epanechnikov']),2/9)
k4=lambda u:(9-15*u*u)/8 if abs(u)<=1 else 0
for j,value in [(0,1),(1,0),(2,0),(3,0),(4,-3/35)]:
    close(quad(lambda u:u**j*k4(u),-1,1)[0],value)
close(quad(lambda u:k4(u)**2,-1,1)[0],9/8)

cv_results={}
dat=np.array([0.,1.,2.]);n=len(dat)
d=np.abs(dat[:,None]-dat[None,:]);mask=~np.eye(n,dtype=bool)
for h,want in [(.75,26/81),(1.5,-17/81)]:
    integrated=np.maximum(2*h-d,0).sum()/(4*n*n*h*h)
    loo=(.5*(d<=h)*mask).sum()/((n-1)*h)
    cv=integrated-2*loo/n
    close(cv,want)
    # Independent integration of KDE squared on intervals between its jumps.
    edges=np.unique(np.r_[dat-h,dat+h])
    direct=sum(quad(lambda x:float(kde(x,h,kernels['Uniform'],dat))**2,a,b)[0]
               for a,b in zip(edges[:-1],edges[1:]))
    close(direct,integrated)
    cv_results[str(h)]={'integrated_square':integrated,'loo_sum':loo,'cv':cv}
report['CV']=cv_results
weights=kernels['Epanechnikov']((3-xdata)/2)
close(np.dot(weights,[2,3,7,8])/weights.sum(),5)
report['rule_example']={'NR_1.06':1.06*2*100**(-.2),'Silverman_0.9':.9*2*100**(-.2)}

# Expected boundary estimators, exact for Uniform and exponential density.
def boundary_expectation(x,h):
    return (np.exp(-np.maximum(0,x-h))-np.exp(-(x+h)))/(2*h)
def reflected_expectation(x,h):
    return boundary_expectation(x,h)+np.where(x<h,(1-np.exp(-np.maximum(0,h-x)))/(2*h),0)
close(boundary_expectation(0,.2),(1-math.exp(-.2))/.4)
close(reflected_expectation(0,.2),(1-math.exp(-.2))/.2)

plt.rcParams.update({'font.size':9,'axes.spines.top':False,'axes.spines.right':False,
                     'axes.grid':True,'grid.alpha':.2,'figure.dpi':160})
fig,ax=plt.subplots(2,2,figsize=(10,8.6),layout='constrained')
u=np.linspace(-2.6,2.6,1601)
for name,k in kernels.items():ax[0,0].plot(u,k(u),label=name,lw=1.6)
ax[0,0].set(title='A. Kernel shapes',xlabel='u',ylabel='K(u)');ax[0,0].legend(fontsize=8)
x=np.linspace(-2,8,1200)
for h in [.25,.7,1.5]:ax[0,1].plot(x,kde(x,h,phi),label=f'h = {h}')
ax[0,1].plot(xdata,np.zeros(4),'|',color='black',ms=9)
ax[0,1].set(title='B. Same data, different bandwidths',xlabel='x',ylabel='Gaussian KDE');ax[0,1].legend()
h=np.linspace(.25,1.4,500);A=.399**2/100;B=.6*.399/100
opt=(B/(4*A))**.2
ax[1,0].plot(h,A*h**4,label='Squared bias');ax[1,0].plot(h,B/h,label='Variance')
ax[1,0].plot(h,A*h**4+B/h,label='AMSE',color='black')
ax[1,0].axvline(opt,ls='--',color='gray',label=f'Optimal h = {opt:.4f}')
ax[1,0].set(title='C. Pointwise AMSE at x = 0',xlabel='h',ylabel='Approximate error');ax[1,0].legend(fontsize=8)
x=np.linspace(0,1.2,600)
ax[1,1].plot(x,np.exp(-x),color='black',label='True exponential density')
ax[1,1].plot(x,boundary_expectation(x,.2),label='Expected ordinary KDE')
ax[1,1].plot(x,reflected_expectation(x,.2),label='Expected reflection KDE')
ax[1,1].set(title='D. Boundary correction (Uniform, h = 0.2)',xlabel='x >= 0',ylabel='Density / expectation');ax[1,1].legend(fontsize=8)
fig.savefig(ROOT/'test_mo_rong_figures.pdf',metadata={'Title':'Kernel density estimation illustrations','Author':''})
plt.close(fig)
# Additional mathematical checks for Chapter 2 lessons.
hist_data=np.array([.1,.2,.4,.8])
hist_report={}
for m,wanted in [(2,-.75),(4,1/6)]:
    h=1/m
    counts=np.histogram(hist_data,bins=np.linspace(0,1,m+1))[0]
    ps=counts/len(hist_data)
    cv=2/((len(hist_data)-1)*h)-(len(hist_data)+1)/((len(hist_data)-1)*h)*np.sum(ps**2)
    integral=np.sum((counts/(len(hist_data)*h))**2)*h
    per_point_count=counts[np.minimum((hist_data*m).astype(int),m-1)]
    loo=np.sum((per_point_count-1)/((len(hist_data)-1)*h))
    close(cv,integral-2*loo/len(hist_data));close(cv,wanted)
    close(np.sum(counts/(len(hist_data)*h))*h,1)
    # Step-basis projection equals the density histogram in each bin.
    ahat=np.sqrt(m)*counts/len(hist_data)
    close(np.sum(ahat**2),integral)
    assert np.allclose(ahat*np.sqrt(m),counts/(len(hist_data)*h))
    hist_report[str(m)]={'counts':counts.tolist(),'cv':float(cv),'heights':(counts/(len(hist_data)*h)).tolist()}
close(.3*.7/(20*.25**2),.168)
report['Histogram']=hist_report

basis=[lambda x:1.,lambda x:np.sqrt(2)*np.cos(2*np.pi*x),lambda x:np.sqrt(2)*np.sin(2*np.pi*x)]
for j in range(3):
    for k in range(3):close(quad(lambda x:basis[j](x)*basis[k](x),0,1)[0],float(j==k))
proj_data=np.array([0.,0.,.25,.25])
coeffs=np.array([np.mean([f(x) for x in proj_data]) for f in basis])
assert np.allclose(coeffs,[1,math.sqrt(2)/2,math.sqrt(2)/2])
proj=lambda x:sum(a*f(x) for a,f in zip(coeffs,basis))
close(quad(proj,0,1)[0],1);close(proj(.625),1-math.sqrt(2))
close(quad(lambda x:proj(x)**2,0,1)[0],sum(coeffs**2))
scores={str(d):float(-sum(coeffs[:d]**2)+2*d/4) for d in [1,3]}
close(scores['1'],-.5);close(scores['3'],-.5)
report['Projection']={'coefficients':coeffs.tolist(),'density_at_5_over_8':proj(.625),'model_scores':scores}

counts=np.array([4.,8.,12.,16.]);k=4;nroot=40
Y=np.sqrt((k/nroot)*(counts+.25))
root_heights=k*(counts+.25)/(nroot+k/4)
close(np.sum(root_heights)/k,1)
close((.8**2+1.2**2)/2,1.04)
close(.8**2/1.04,8/13);close(1.2**2/1.04,18/13)
report['RootUnroot']={'Y':Y.tolist(),'sigma_squared':k/(4*nroot),'sigma':math.sqrt(k/(4*nroot)),
                      'unsmoothed_normalized_heights':root_heights.tolist()}

multi_data=np.array([[0.,0.],[1.,1.]])
value=np.prod(phi((np.array([0.,0.])-multi_data)),axis=1).mean()
close(value,(1+math.exp(-1))/(4*math.pi))
# Normalization independently along two scaled axes.
for center,h1,h2 in [(multi_data[0],1.,2.),(multi_data[1],.5,1.5)]:
    factor1=quad(lambda x:float(phi((x-center[0])/h1))/h1,-np.inf,np.inf)[0]
    factor2=quad(lambda x:float(phi((x-center[1])/h2))/h2,-np.inf,np.inf)[0]
    close(factor1*factor2,1)
from scipy.optimize import minimize_scalar
opts={}
for d in [1,2,10]:
    A=.2;B=.7;ns=1000
    hopt=(d*B/(4*A*ns))**(1/(d+4))
    fun=lambda h:A*h**4+B/(ns*h**d)
    numeric=minimize_scalar(fun,bounds=(hopt*.5,hopt*2),method='bounded',options={'xatol':1e-12})
    assert abs(numeric.x-hopt)<1e-7
    close(B/(ns*hopt**d),4*A*hopt**4/d)
    opts[str(d)]={'hopt':hopt,'rate_exponent':4/(d+4)}
report['Multivariate']={'gaussian_2d_at_zero':float(value),'optimal_bandwidth_checks':opts}

# Independent numerical checks for the 45-minute exercise supplement.
for sigma in [.7, 2.]:
    second_derivative = lambda x: (((x - 1.3) / sigma)**2 - 1) * float(phi((x - 1.3) / sigma)) / sigma**3
    numeric_r = quad(lambda x: second_derivative(x)**2, -np.inf, np.inf)[0]
    close(numeric_r, 3 / (8 * sqrtpi * sigma**5))
close((4 / 3)**.2, 1.0592238410488122)

# Contrast: integrate g^2 and evaluate g on the sample, then compare with
# the completed-square identity for several coefficient vectors.
for trial in [np.zeros(3), coeffs, np.array([1.2, -.3, .7])]:
    g = lambda x: sum(a * fun(x) for a, fun in zip(trial, basis))
    direct = quad(lambda x: g(x)**2, 0, 1)[0] - 2 * np.mean([g(x) for x in proj_data])
    completed = np.sum((trial - coeffs)**2) - np.sum(coeffs**2)
    close(direct, completed)
    assert direct >= -np.sum(coeffs**2) - 1e-10

# Pythagoras checked against integration of the actual density f(x)=2x.
true_coeffs = np.array([quad(lambda x: 2*x*fun(x), 0, 1)[0] for fun in basis])
projection_true = lambda x: sum(a*fun(x) for a, fun in zip(true_coeffs, basis))
total_error = quad(lambda x: (2*x - proj(x))**2, 0, 1)[0]
approx_error = quad(lambda x: (2*x - projection_true(x))**2, 0, 1)[0]
est_error = quad(lambda x: (projection_true(x) - proj(x))**2, 0, 1)[0]
close(total_error, approx_error + est_error)
close(est_error, np.sum((true_coeffs - coeffs)**2))

# Integer D: compare the adjacent-integer rule with exhaustive search,
# including a continuous optimum below the admissible minimum of 1.
dimension_checks = []
for alpha, cf, phi0, ns in [(2., 1., 1., 100), (.5, .01, 2., 10), (1.5, .8, 2., 300)]:
    continuous = (2*alpha*cf**2*ns/phi0)**(1/(2*alpha+1))
    risk_bound = lambda dim: cf**2*dim**(-2*alpha) + phi0*dim/ns
    candidates = {max(1, math.floor(continuous)), max(1, math.ceil(continuous))}
    chosen = min(candidates, key=lambda dim: (risk_bound(dim), dim))
    brute = min(range(1, 1001), key=lambda dim: (risk_bound(dim), dim))
    assert chosen == brute
    dimension_checks.append({'continuous': continuous, 'integer': chosen})

# Reflection: verify mass directly for a Gaussian mixture on the half-line.
for center in [0., .3, 2.]:
    bandwidth = .4
    reflected = lambda x: (float(phi((x-center)/bandwidth)) + float(phi((x+center)/bandwidth))) / bandwidth
    close(quad(reflected, 0, np.inf)[0], 1.)
for bandwidth in [.01, .005]:
    reflection_bias = -math.expm1(-bandwidth)/bandwidth - 1
    assert abs(reflection_bias/bandwidth + .5) < bandwidth/6

# Gaussian LOOCV: compare the sum formula with numerical integration and
# independently constructed n-1 estimators evaluated at their held-out point.
cv_bandwidth = .8
cv_sample = np.array([0., 1., 2.])
cv_n = len(cv_sample)
pair_u = (cv_sample[:, None] - cv_sample[None, :]) / cv_bandwidth
correlation = np.exp(-pair_u**2/4) / (2*sqrtpi)
gaussian_pairs = correlation.sum() / (cv_n**2*cv_bandwidth)
gaussian_pairs -= 2*np.sum(phi(pair_u)[~np.eye(cv_n, dtype=bool)]) / (cv_n*(cv_n-1)*cv_bandwidth)
cv_direct = quad(lambda x: float(kde(x, cv_bandwidth, phi, cv_sample))**2, -np.inf, np.inf)[0]
cv_direct -= 2*np.mean([float(kde(x, cv_bandwidth, phi, np.delete(cv_sample, i))) for i, x in enumerate(cv_sample)])
close(gaussian_pairs, cv_direct)
model_scores = [-1.10 + 2*2/100, -1.17 + 2*4/100, -1.20 + 2*8/100]
assert [2, 4, 8][int(np.argmin(model_scores))] == 4
report['Exercises45min'] = {
    'normal_reference_coefficient': (4/3)**.2,
    'normal_reference_n100_s2_rounded': 1.06*2*100**(-.2),
    'pythagoras': {'total': total_error, 'approximation': approx_error, 'estimation': est_error},
    'dimension_checks': dimension_checks,
    'gaussian_loocv': float(cv_direct),
    'penalized_model_scores': model_scores,
}

# Exact finite-distribution check of the expanded risk-reformulation exercise.
# f(x)=2x on [0,1], two equal bins, n=5; sum all possible left-bin counts.
hw_n = 5
hw_p = .25
hw_f_norm = quad(lambda x: (2*x)**2, 0, 1)[0]
hw_projection_norm = .5*(.5**2 + 1.5**2)
hw_bias_squared = quad(lambda x: (2*x-.5)**2, 0, .5)[0]
hw_bias_squared += quad(lambda x: (2*x-1.5)**2, .5, 1)[0]
hw_variance = (2-hw_projection_norm)/hw_n
hw_mean_norm = hw_mean_variance_hat = hw_mean_score = hw_mean_risk = 0.
for count in range(hw_n+1):
    probability = math.comb(hw_n, count)*hw_p**count*(1-hw_p)**(hw_n-count)
    heights = [2*count/hw_n, 2*(hw_n-count)/hw_n]
    sample_norm = .5*sum(v*v for v in heights)
    # Compute variance estimates from the actual basis values, independently
    # of the compact (D - squared_norm)/(n-1) identity in the solution.
    basis_values = np.array([[math.sqrt(2), 0.]]*count + [[0., math.sqrt(2)]]*(hw_n-count))
    variance_hat = np.var(basis_values, axis=0, ddof=1).sum()/hw_n
    close(variance_hat, (2-sample_norm)/(hw_n-1))
    sample_error = quad(lambda x: (2*x-heights[0])**2, 0, .5)[0]
    sample_error += quad(lambda x: (2*x-heights[1])**2, .5, 1)[0]
    hw_mean_norm += probability*sample_norm
    hw_mean_variance_hat += probability*variance_hat
    hw_mean_score += probability*(-sample_norm + 2*variance_hat)
    hw_mean_risk += probability*sample_error
close(hw_bias_squared, hw_f_norm-hw_projection_norm)
close(hw_bias_squared, 1/12)
close(hw_variance, 3/20)
close(hw_mean_norm, hw_projection_norm+hw_variance)
close(hw_mean_variance_hat, hw_variance)
close(hw_mean_risk, hw_bias_squared+hw_variance)
close(hw_mean_risk, 7/30)
close(hw_mean_score, hw_mean_risk-hw_f_norm)
close(hw_mean_score, -11/10)

# Check expected CV against an independently integrated exact MISE under a
# standard-normal density, without Monte Carlo error or asymptotic formulas.
hw_cv_checks = {}
for bandwidth in [.3, .8]:
    fh_sigma = math.sqrt(1+bandwidth**2)
    fh = lambda x: float(phi(x/fh_sigma))/fh_sigma
    expected_square_kernel = lambda x: float(phi(x/math.sqrt(1+bandwidth**2/2))) / math.sqrt(1+bandwidth**2/2) / (2*sqrtpi*bandwidth)
    exact_mise = quad(lambda x: (fh(x)-float(phi(x)))**2 + (expected_square_kernel(x)-fh(x)**2)/hw_n, -np.inf, np.inf)[0]
    difference_density = lambda t: float(phi(t/math.sqrt(2)))/math.sqrt(2)
    expected_cross = quad(lambda t: float(phi(t/bandwidth))/bandwidth*difference_density(t), -np.inf, np.inf)[0]
    expected_autocorrelation = quad(lambda t: math.exp(-t*t/(4*bandwidth**2))/(2*sqrtpi*bandwidth)*difference_density(t), -np.inf, np.inf)[0]
    expected_cv = 1/(2*sqrtpi*hw_n*bandwidth) + (hw_n-1)/hw_n*expected_autocorrelation - 2*expected_cross
    close(expected_cv, exact_mise-1/(2*sqrtpi))
    hw_cv_checks[str(bandwidth)] = {'MISE_exact': exact_mise, 'expected_CV': expected_cv}

# Verify the closed-form minimum AMISE coefficient in the Gaussian exercise.
for sigma in [.7, 2.]:
    optimum = (4/3)**.2*sigma*100**(-.2)
    minimum = 3*optimum**4/(32*sqrtpi*sigma**5) + 1/(2*sqrtpi*100*optimum)
    close(minimum, 5*3**.2/(2**(17/5)*sqrtpi*sigma)*100**(-.8))
report['RiskReformulation'] = {
    'bias_squared': hw_bias_squared, 'variance': hw_variance,
    'risk': hw_mean_risk, 'expected_empirical_variance': hw_mean_variance_hat,
    'expected_corrected_contrast': hw_mean_score,
    'expected_CV_checks': hw_cv_checks,
}

(ROOT/'test_mo_rong_kiem_tra.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n')
print(json.dumps(report,indent=2))
print('All numerical checks passed.')
