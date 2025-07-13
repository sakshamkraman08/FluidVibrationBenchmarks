# Numerical Scheme

- **Grid**: 129×129 staggered MAC grid  
- **Time stepping**: Projection method with CFL-limited \(\Delta t\)  
- **Pressure solver**: SOR (ω=1.7, tol=1e-6)  
- **Validation**: RMS error < 0.01 against Ghia et al. data [8].
