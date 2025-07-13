using Plots

# Beam properties
E = 2e11        # Young's modulus (Pa)
I_moment = 1e-6 # Moment of inertia (m^4)
rho = 7800      # Density (kg/m^3)
A = 0.01        # Cross-sectional area (m^2)
L = 2.0         # Length (m)

# Natural frequencies (analytical)
n_modes = 3
omega = [(n*pi/L)^2 * sqrt(E*I_moment/(rho*A)) for n in 1:n_modes]
freqs = omega ./ (2*pi)

# Mode shapes - FIX: Use broadcasting with .sin
x = range(0, L, length=100)
modes = [sin.(n*pi*x/L) for n in 1:n_modes]

# Plot mode shapes correctly
plot(x, modes[1], label="Mode 1: $(round(freqs[1], digits=2)) Hz", linewidth=2)
plot!(x, modes[2], label="Mode 2: $(round(freqs[2], digits=2)) Hz", linestyle=:dash)
plot!(x, modes[3], label="Mode 3: $(round(freqs[3], digits=2)) Hz", linestyle=:dot)
xlabel!("Position (m)")
ylabel!("Normalized Amplitude")
title!("First Three Beam Mode Shapes")


# Create images directory if it doesn't exist
if !isdir("../FluidVibrationBenchmarks/Visual_Results/Week2/images")
    mkdir("../FluidVibrationBenchmarks/Visual_Results/Week2/images")
end
savefig("../FluidVibrationBenchmarks/Visual_Results/Week2/images/beam_modes.png")

println("Beam vibration simulation completed! Plot saved to ../FluidVibrationBenchmarks/Visual_Results/Week2/images/beam_modes.png")
println("Natural frequencies: $(round.(freqs, digits=2)) Hz")