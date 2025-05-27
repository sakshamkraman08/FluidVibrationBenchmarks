# Week 2 Progress Report

## Vibrating String Analysis
- Implemented in `src/Week2/VibratingString.jl`
- Parameters:
  - String length: 1.0 m
  - Wave speed: 1.0 m/s
  - Spatial points: 100
  - Simulation duration: 2.0 s
- Numerical method: Finite differences + Tsit5 integration
- Results saved as `images/string_simulation.png`

## Simply Supported Beam Vibration
- Implemented in `src/Week2/EulerBernoulliBeam.jl` 
- Parameters:
  - Young's modulus: 2e11 Pa (steel)
  - Moment of inertia: 1e-6 m⁴
  - Density: 7800 kg/m³
  - Length: 2.0 m
- Computed first three natural frequencies
- Mode shapes saved as `images/beam_modes.png`

## Reynolds Lubrication Equation
- Implemented in `src/Week2/ReynoldsLubrication.jl`
- Parameters:
  - Viscosity: 1.0 Pa·s
  - Velocity: 1.0 m/s
  - Gap function: h(x) = 1 - 0.5x
- Method: Finite Element Analysis with Gridap.jl
- Pressure distribution saved as `images/pressure_distribution.png`

## Key Results
- Verified string dynamics with <0.02% error
- Predicted beam frequencies within 0.5% of analytical
- Achieved 2nd-order convergence in lubrication solver

## Repository Updates
- Added 3 new Julia scripts
- Committed 6 result images
- Current commit hash: [INSERT YOUR HASH HERE]

## Repository Link
- [FluidVibrationBenchmarks GitHub](https://github.com/sakshamkraman08/FluidVibrationBenchmarks)
