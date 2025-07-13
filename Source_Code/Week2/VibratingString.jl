using LinearAlgebra
using DifferentialEquations, Plots

# Parameters
L = 1.0        # String length (meters)
c = 1.0        # Wave speed (m/s)
Nx = 100       # Number of spatial points
tspan = (0.0, 2.0) # Simulation time

# Spatial grid
x = range(0, L, length=Nx)
dx = x[2] - x[1]  # Grid spacing

# Finite difference matrix
A = -2*I + diagm(1 => ones(Nx-1), -1 => ones(Nx-1))
A[1, :] .= 0; A[end, :] .= 0 # Dirichlet boundary conditions

# ODE system
function wave_eq!(du, u, p, t)
    du[1:Nx] = u[Nx+1:end]         # Velocity terms
    du[Nx+1:end] = (c^2/dx^2) * (A * u[1:Nx]) # Acceleration terms
end

# Initial conditions
u0 = x .* (L .- x)  # Initial displacement (parabolic shape)
v0 = zeros(Nx)      # Initial velocity (zero)
prob = ODEProblem(wave_eq!, [u0; v0], tspan)

# Solve the ODE (CORRECTED - explicitly use DifferentialEquations.solve)
sol = DifferentialEquations.solve(prob, Tsit5(), saveat=0.1)

# Plot at different times
plot(x, sol[1:Nx, 1], label="t=0.0s", linewidth=2)
plot!(x, sol[1:Nx, 6], label="t=0.5s", linestyle=:dash)
plot!(x, sol[1:Nx, 11], label="t=1.0s", linestyle=:dot)
xlabel!("Position (m)")
ylabel!("Displacement")
title!("Vibrating String at Different Times")

# Create images directory if it doesn't exist
if !isdir("../FluidVibrationBenchmarks/Visual_Results/Week2/images")
    mkdir("../FluidVibrationBenchmarks/Visual_Results/Week2/images")
end
savefig("../FluidVibrationBenchmarks/Visual_Results/Week2/images/string_simulation.png")

println("String simulation completed! Plot saved to ../FluidVibrationBenchmarks/Visual_Results/Week2/images/string_simulation.png")
