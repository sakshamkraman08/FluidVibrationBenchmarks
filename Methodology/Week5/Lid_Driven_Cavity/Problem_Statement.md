# Lid-Driven Cavity Flow

Compute steady incompressible flow in a unit square driven by a moving top lid (speed = 1 m/s), solving the Navier–Stokes equations:
\[
\partial_t\mathbf{u} + (\mathbf{u}\cdot\nabla)\mathbf{u} = -\nabla p + \frac{1}{Re}\nabla^2\mathbf{u},\quad \nabla\cdot\mathbf{u} = 0
\]
Validated against Ghia et al. (1982) centerline velocity benchmarks [8].
