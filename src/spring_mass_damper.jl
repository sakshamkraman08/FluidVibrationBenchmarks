using DifferentialEquations
using Plots

# Spring-mass-damper ODE definition
function spring_mass!(du, u, p, t)
    m, c, k = p
    du[1] = u[2]
    du[2] = (-c*u[2] - k*u[1])/m
end

# Parameters
p = (10.0, 5.0, 100.0)
u0 = [0.5, 0.0]
tspan = (0.0, 10.0)

# Solve ODE
prob = ODEProblem(spring_mass!, u0, tspan, p)
sol = solve(prob, Tsit5(), reltol=1e-8, abstol=1e-8)

# Create images directory if missing
!isdir("../FluidVibrationBenchmarks/images") && mkdir("../FluidVibrationBenchmarks/images")

# Plot and save
plot(sol, idxs=(0,1), title="Displacement vs Time", 
     xlabel="Time (s)", ylabel="Displacement (m)")
savefig("../FluidVibrationBenchmarks/images/displacement_plot.png")
