# Numerical Solution Approach

We nondimensionalized the equation to:
$$
\ddot{x} + 2\zeta\omega_n\dot{x} + \omega_n^2\,x = 0,
$$
with \(\omega_n=\sqrt{k/m}\) [1].

An explicit finite-difference scheme of second-order accuracy in time was implemented in Julia, choosing the time step \(\Delta t\) to satisfy \(\zeta \omega_n \Delta t < 0.5\) for numerical stability [2].

Simulation results were compared against the analytical solution \(x(t)=x_0e^{-\zeta\omega_n t}\cos(\omega_d t)\) to verify accuracy [1].
