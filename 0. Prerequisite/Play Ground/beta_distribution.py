import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import beta
from scipy.special import beta as beta_function

def beta_pdf(x, r, s):
    """
    Calculate the Beta distribution PDF
    
    Parameters:
    -----------
    x : float or array-like
        Value(s) at which to evaluate the PDF
    r : float
        Shape parameter (r > 0)
    s : float
        Shape parameter (s > 0)
    
    Returns:
    --------
    pdf : float or array-like
        PDF value(s)
    """
    # Beta function B(r,s)
    B_rs = beta_function(r, s)
    
    # Calculate PDF
    if isinstance(x, (int, float)):
        if 0 <= x <= 1:
            return (x**(r-1) * (1-x)**(s-1)) / B_rs
        else:
            return 0
    else:
        # For array input
        pdf = np.zeros_like(x)
        mask = (x >= 0) & (x <= 1)
        pdf[mask] = (x[mask]**(r-1) * (1-x[mask])**(s-1)) / B_rs
        return pdf

# Example: Plot Beta distribution with different parameters
x = np.linspace(0, 1, 1000)

# Different parameter combinations
params = [
    (2, 2, 'r=2, s=2 (symmetric)'),
    (2, 5, 'r=2, s=5 (right-skewed)'),
    (5, 2, 'r=5, s=2 (left-skewed)'),
    (0.5, 0.5, 'r=0.5, s=0.5 (U-shaped)')
]

plt.figure(figsize=(10, 6))

for r, s, label in params:
    pdf = beta_pdf(x, r, s)
    plt.plot(x, pdf, label=label, linewidth=2)

plt.title('Beta Distribution PDF for Different Parameters', fontsize=14)
plt.xlabel('x', fontsize=12)
plt.ylabel('f(x) - Probability Density', fontsize=12)
plt.legend(fontsize=10)
plt.grid(True, alpha=0.3)
plt.xlim(0, 1)
plt.ylim(0, None)

# Add formula as text
formula_text = r'$f(x) = \frac{x^{r-1}(1-x)^{s-1}}{B(r,s)}$ for $0 \leq x \leq 1$'
plt.text(0.5, plt.ylim()[1]*0.95, formula_text, 
         ha='center', va='top', fontsize=11, 
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.show()

# Verify with scipy
print("\nVerification with scipy.stats.beta:")
print(f"Custom PDF at x=0.5 (r=2, s=2): {beta_pdf(0.5, 2, 2):.6f}")
print(f"Scipy PDF at x=0.5 (r=2, s=2): {beta.pdf(0.5, 2, 2):.6f}")
