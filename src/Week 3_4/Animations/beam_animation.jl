using Plots, LinearAlgebra

function animate_vibrating_beam()
    # Parameters
    E = 2e11; I = 1e-6; rho = 7800; A = 0.01; L = 2.0
    
    # Natural frequencies and mode shapes
    omega = [(n*π/L)^2 * sqrt(E*I/(rho*A)) for n in 1:3]
    x = range(0, L, length=100)
    modes = [sin.(n*π*x/L) for n in 1:3]
    
    # Animate each mode
    for mode_num in 1:3
        anim = @animate for t in range(0, 2π, length=60)
            amplitude = cos(omega[mode_num] * t)
            y = amplitude * modes[mode_num]
            
            plot(x, y, ylim=(-1.2, 1.2), xlim=(0, L),
                 linewidth=3,
                 title="Beam Mode $(mode_num) - f = $(round(omega[mode_num]/(2π), digits=2)) Hz",
                 xlabel="Position (m)", ylabel="Amplitude")
            scatter!([0, L], [0, 0], markersize=8, color=:red)
        end
        gif(anim, "animations/beam_mode_$(mode_num).gif", fps=15)
    end
end

animate_vibrating_beam()
