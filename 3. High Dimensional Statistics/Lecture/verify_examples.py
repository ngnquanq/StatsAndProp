"""Independent numerical checks for the lecture; does not modify any files."""
from __future__ import annotations

import numpy as np
from numpy.testing import assert_allclose
from scipy.optimize import minimize
from scipy.stats import chi2, f, norm, t


def t_squared(data: np.ndarray, null_mean: np.ndarray):
    n, p = data.shape
    mean = data.mean(axis=0)
    cov = np.cov(data, rowvar=False, ddof=1)
    residual = mean - null_mean
    statistic = float(n * residual @ np.linalg.solve(cov, residual))
    f_value = (n - p) * statistic / (p * (n - 1))
    return mean, cov, statistic, f_value, float(f.sf(f_value, p, n - p))


def critical(n: int, p: int, alpha: float = 0.05) -> float:
    return float(p * (n - 1) / (n - p) * f.ppf(1 - alpha, p, n - p))


def check_invariance(data, null_mean, transform, shift):
    transformed = data @ transform.T + shift
    transformed_null = transform @ null_mean + shift
    old = t_squared(data, null_mean)
    new = t_squared(transformed, transformed_null)
    assert_allclose(new[0], transform @ old[0] + shift, atol=1e-12)
    assert_allclose(new[1], transform @ old[1] @ transform.T, atol=1e-12)
    assert_allclose(new[2:], old[2:], rtol=1e-12)


def check_likelihood(data, null_mean, expected_determinants):
    n = len(data)
    mean, cov, statistic, *_ = t_squared(data, null_mean)
    mle = (n - 1) * cov / n
    delta = mean - null_mean
    mle_null = mle + np.outer(delta, delta)
    # Construct the constrained MLE directly from observations as a second route.
    deviations = data - null_mean
    assert_allclose(mle_null, deviations.T @ deviations / n)
    determinants = np.array([np.linalg.det(mle), np.linalg.det(mle_null)])
    assert_allclose(determinants, expected_determinants)
    wilks = determinants[0] / determinants[1]
    assert_allclose((n - 1) * (1 / wilks - 1), statistic)
    assert_allclose(wilks, 1 / (1 + statistic / (n - 1)))
    return wilks, wilks ** (n / 2)


def log_likelihood(data, mean, covariance):
    """Gaussian log-likelihood evaluated from raw observations."""
    n, p = data.shape
    sign, logdet = np.linalg.slogdet(covariance)
    assert sign > 0 and np.linalg.eigvalsh(covariance).min() > 0
    residuals = data - mean
    quadratic = np.sum(residuals * np.linalg.solve(covariance, residuals.T).T)
    return -.5 * (n*p*np.log(2*np.pi) + n*logdet + quadratic)


def check_mle_derivation(data):
    """Check the score, global inequality and an independent numerical optimum."""
    n = len(data)
    mean = data.mean(axis=0)
    centered = data - mean
    scatter = centered.T @ centered
    mle = scatter / n
    precision = np.linalg.inv(mle)
    assert_allclose(mle, [[6, -2.5], [-2.5, 1.5]])
    assert_allclose(.5 * (n*np.linalg.inv(precision) - scatter), 0, atol=1e-12)
    eigenvalues, eigenvectors = np.linalg.eigh(mle)
    square_root = (eigenvectors * np.sqrt(eigenvalues)) @ eigenvectors.T
    for candidate in [2*mle, mle + np.eye(2), np.array([[4., 1], [1, 3]])]:
        whitened = square_root @ np.linalg.solve(candidate, square_root)
        eigen = np.linalg.eigvalsh(whitened)
        actual_gap = log_likelihood(data, mean, candidate) - log_likelihood(data, mean, mle)
        proven_gap = n/2 * np.sum(np.log(eigen) - eigen + 1)
        assert_allclose(actual_gap, proven_gap, atol=1e-12)
        assert actual_gap < 0
    h = np.array([[.2, -.1], [-.1, .3]])
    step = 1e-4
    center = log_likelihood(data, mean, mle)
    plus = log_likelihood(data, mean, np.linalg.inv(precision + step*h))
    minus = log_likelihood(data, mean, np.linalg.inv(precision - step*h))
    assert_allclose((plus-minus)/(2*step), 0, atol=1e-6)
    expected_second = -n/2 * np.trace(mle @ h @ mle @ h)
    assert_allclose((plus+minus-2*center)/step**2, expected_second, rtol=1e-5)

    # Cholesky parametrization ensures every covariance considered is positive definite.
    def decode(parameters):
        lower = np.array([[np.exp(parameters[2]), 0],
                          [parameters[3], np.exp(parameters[4])]])
        return parameters[:2], lower @ lower.T

    def objective(parameters):
        trial_mean, trial_covariance = decode(parameters)
        return -log_likelihood(data, trial_mean, trial_covariance)

    numerical = minimize(objective, [5., 11., np.log(2), 0, np.log(2)],
                         method='BFGS', options={'gtol': 1e-6, 'maxiter': 500})
    numerical_mean, numerical_covariance = decode(numerical.x)
    assert_allclose(numerical_mean, mean, atol=2e-5)
    assert_allclose(numerical_covariance, mle, atol=2e-5)
    assert_allclose(numerical.fun, -center, atol=1e-9)

    # A rank-deficient scatter has no finite maximum over positive-definite covariances.
    singular_data = np.column_stack([data[:, 0], 2*data[:, 0]])
    singular_mean = singular_data.mean(axis=0)
    deviations = singular_data - singular_mean
    values, vectors = np.linalg.eigh(deviations.T @ deviations / n)
    assert_allclose(values[0], 0, atol=1e-12)
    log_values = []
    for epsilon in [1e-2, 1e-3, 1e-4]:
        covariance = (vectors * np.array([epsilon, values[1]])) @ vectors.T
        log_values.append(log_likelihood(singular_data, singular_mean, covariance))
    assert np.all(np.diff(log_values) > 0)
    assert_allclose(np.diff(log_values), n/2*np.log(10), atol=1e-8)


def main():
    sigma = np.array([[4.0, 0, -1], [0, 5, 0], [-1, 0, 2]])
    mu = np.array([1.0, -1, 2])
    assert np.linalg.eigvalsh(sigma).min() > 0
    for a, expected_mean, expected_var in [
        (np.array([3.0, -2, 1]), 7, 52),
        (np.array([1.0, 2, -1]), -3, 28),
    ]:
        assert_allclose(a @ mu, expected_mean)
        diagonal = np.sum(a**2 * np.diag(sigma))
        cross = sum(2 * a[i] * a[j] * sigma[i, j]
                    for i in range(3) for j in range(i + 1, 3))
        assert_allclose(a @ sigma @ a, expected_var)
        assert_allclose(diagonal + cross, expected_var)

    # Conditional vector, computed from blocks rather than a quoted answer.
    uv = sigma[:2, 2:]
    vv = sigma[2:, 2:]
    regression = np.linalg.solve(vv, uv.T).T
    conditional_mean = mu[:2] + regression @ (np.array([4.0]) - mu[2:])
    conditional_cov = sigma[:2, :2] - regression @ uv.T
    assert_allclose(conditional_mean, [0, -1])
    assert_allclose(conditional_cov, np.diag([3.5, 5]))
    a, b = np.array([1, 0, 5 / 3]), np.array([1, 0, -1])
    assert_allclose(a @ sigma @ b, 0, atol=1e-12)

    geometry_cov = np.array([[4.0, 3], [3, 4]])
    for point, expected in [(np.array([2.0, 2]), 8 / 7),
                            (np.array([2.0, -2]), 8)]:
        assert_allclose(point @ np.linalg.solve(geometry_cov, point), expected)
    assert_allclose(chi2.ppf(.95, 2), 5.9915, atol=5e-5)

    data4 = np.array([[2.0, 12], [8, 9], [6, 9], [8, 10]])
    mean4, cov4, stat4, f4, p4 = t_squared(data4, np.array([7.0, 11]))
    assert_allclose(mean4, [6, 10])
    assert_allclose(cov4, [[8, -10 / 3], [-10 / 3, 2]])
    assert_allclose(np.linalg.inv(cov4), np.array([[9, 15], [15, 36]]) / 22)
    assert_allclose([stat4, f4, p4], [150 / 11, 50 / 11, 11 / 61])
    assert_allclose(critical(4, 2), 57)
    assert stat4 < critical(4, 2) and stat4 > chi2.ppf(.95, 2)
    assert_allclose(check_likelihood(data4, np.array([7.0, 11]), [44/16, 244/16]),
                    [11/61, (11/61)**2])
    assert_allclose(t.ppf(.975, 3) * np.sqrt(8 / 4), 4.500658726,
                    atol=1e-8)
    check_mle_derivation(data4)
    # A dense, nonsymmetric affine map tests mixing, scaling and translation together.
    check_invariance(data4, np.array([7., 11.]), np.array([[2., -1], [.5, 3]]),
                     np.array([5., -2.]))

    data3 = np.array([[6.0, 9], [10, 6], [8, 3]])
    assert_allclose(t_squared(data3, np.array([9.0, 5]))[2], 7/9)
    check_invariance(data3, np.array([9.0, 5]), np.array([[1.0, -1], [1, 1]]),
                     np.zeros(2))

    # n=40 is an explicitly hypothetical summary, separate from data4.
    cov40 = np.array([[4.0, 3], [3, 9]])
    c40 = critical(40, 2)
    directions = np.array([[1.0, 0], [0, 1], [1, -1], [2, -1]])
    variances = np.einsum('ij,jk,ik->i', directions, cov40, directions)
    assert_allclose(variances, [4, 9, 7, 13])
    standard_errors = np.sqrt(variances / 40)
    widths_t = np.sqrt(c40) * standard_errors
    widths_b3 = t.ppf(1 - .05/6, 39) * standard_errors[:3]
    assert_allclose(widths_t, [.8161, 1.2242, 1.0796, 1.4713], atol=5e-5)
    assert_allclose(widths_b3, [.7911, 1.1866, 1.0465], atol=5e-5)
    width_b4 = t.ppf(1 - .05/8, 39) * standard_errors[3]
    assert_allclose(width_b4, 1.4930, atol=5e-5)
    assert width_b4 > widths_t[3]
    corner = np.array([.75, -1.1])
    assert np.all(np.abs(corner) < widths_t[:2])
    assert_allclose(40 * corner @ np.linalg.solve(cov40, corner), 22.0037, atol=5e-5)
    # Every plotted ellipse point is on the boundary; projected extents agree.
    theta = np.linspace(0, 2*np.pi, 10001)
    ellipse = np.sqrt(c40 / 40) * np.linalg.cholesky(cov40) @ np.array(
        [np.cos(theta), np.sin(theta)])
    assert_allclose(40 * np.sum(ellipse * np.linalg.solve(cov40, ellipse), axis=0),
                    c40, atol=1e-10)
    assert_allclose(np.max(np.abs(ellipse), axis=1), widths_t[:2], atol=1e-6)

    # Bonferroni rectangle for ONLY the two component means (m=2).
    widths_b2 = t.ppf(.9875, 39) * np.sqrt(np.diag(cov40)/40)
    assert_allclose(widths_b2, [.7372, 1.1058], atol=5e-5)
    for delta, expected_t, in_bonferroni, in_ellipse in [
        (np.array([.70, -1.05]), 19.6, True, False),
        (np.array([.80, .60]), 6.4, False, True),
    ]:
        value = 40*delta @ np.linalg.solve(cov40, delta)
        assert_allclose(value, expected_t)
        assert bool(np.all(abs(delta) <= widths_b2)) == in_bonferroni
        assert bool(value <= c40) == in_ellipse
    evals, evecs = np.linalg.eigh(cov40)
    assert_allclose(evals, [(13-np.sqrt(61))/2, (13+np.sqrt(61))/2])
    assert_allclose(np.sqrt(c40*evals/40), [.6573, 1.3163], atol=5e-5)
    assert_allclose(abs(evecs[:, 1]), [.4242, .9056], atol=5e-5)
    angle = np.degrees(np.arctan2(abs(evecs[1, 1]), abs(evecs[0, 1])))
    assert_allclose(angle, 64.9, atol=.05)
    for rho in [-.5, 0, .5]:
        family_cov = np.array([[4., 6*rho], [6*rho, 9.]])
        assert np.linalg.eigvalsh(family_cov).min() > 0
        assert_allclose(t.ppf(.9875, 39) * np.sqrt(np.diag(family_cov)/40), widths_b2)
        # The three TikZ ellipses use this explicit parametrization.
        curve = np.array([widths_t[0]*np.cos(theta),
                          widths_t[1]*(rho*np.cos(theta)+np.sqrt(1-rho**2)*np.sin(theta))])
        assert_allclose(40*np.sum(curve*np.linalg.solve(family_cov, curve), axis=0),
                        c40, atol=1e-10)
        # Check the expanded correlation equation against the matrix form.
        delta = np.array([.7, -1.05])
        expanded = 40/(1-rho**2) * (
            delta[0]**2/4 - 2*rho*delta[0]*delta[1]/6 + delta[1]**2/9)
        assert_allclose(expanded, 40*delta @ np.linalg.solve(family_cov, delta))
    negative_cov = np.array([[4., -3], [-3, 9.]])
    assert_allclose(np.array([2., -1]) @ negative_cov @ np.array([2., -1]), 37)

    # Finite-sample one-dimensional reduction, checked at several sample sizes.
    for n in [4, 10, 40, 100]:
        assert_allclose(critical(n, 1), t.ppf(.975, n-1)**2, rtol=1e-10)
    assert_allclose(critical(100, 2), 6.2415, atol=5e-5)
    assert t.ppf(1-.05/20000, 99) > np.sqrt(critical(100, 2))

    data5 = np.array([[1.0, 2], [2, 1], [3, 4], [4, 3], [5, 5]])
    mean5, cov5, stat5, f5, p5 = t_squared(data5, np.array([2.0, 2]))
    assert_allclose(mean5, [3, 3])
    assert_allclose(cov5, [[2.5, 2], [2, 2.5]])
    assert_allclose([stat5, f5], [20/9, 5/6])
    assert_allclose(critical(5, 2), 25.4723, atol=5e-5)
    assert_allclose(p5, .5154, atol=5e-5)
    check_invariance(data5, np.array([2.0, 2]), np.diag([100.0, .1]),
                     np.array([5.0, -2]))
    wilks5, lr5 = check_likelihood(data5, np.array([2.0, 2]), [1.44, 2.24])
    assert_allclose([wilks5, lr5], [9/14, (9/14)**2.5])

    # Large-sample exercises and main example.
    assert_allclose(100 * np.array([-1.0, -1]) @ np.linalg.solve(
        cov4, np.array([-1.0, -1])), 340.9091, atol=5e-5)
    assert_allclose(np.sqrt(chi2.ppf(.95, 2) * np.diag(cov4) / 100),
                    [.6923, .3462], atol=5e-5)
    assert_allclose(chi2.sf(5, 2), np.exp(-2.5))
    assert_allclose(np.sqrt(chi2.ppf(.95, 2)/100), .2448, atol=5e-5)
    assert_allclose(norm.ppf(.9875)/10, .2241, atol=5e-5)

    print('PASS: linear moments, conditional blocks, Mahalanobis geometry')
    print('PASS: small-sample T²/F/p-value, MLE determinants, affine invariance')
    print('PASS: interval widths, ellipse/projection, Bonferroni counterexample')
    print('PASS: p=1 reduction, exercise answers, large-sample calculations')
    print('PASS: MLE score/global maximum, numerical optimization, singular scatter')
    print('PASS: dense affine invariance, three regions, correlation family, ellipse axes')
    print(f'n=4: T²={stat4:.6f}, F={f4:.6f}, p={p4:.6f}, critical=57')
    print(f'n=40: critical={c40:.6f}, T² widths={widths_t.round(6)}')
    print(f'Bonferroni m=4: multiplier={t.ppf(1-.05/8,39):.6f}, width={width_b4:.6f}')


if __name__ == '__main__':
    main()
