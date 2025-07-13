using Plots, DifferentialEquations, LinearAlgebra

function animate_vibrating_string()
    # Parameters
    L = 1.0        # String length (m)
    c = 1.0        # Wave speed (m/s)  
    Nx = 100       # Spatial points
    tspan = (0.0, 2.0)
    
    # Spatial grid
    x = range(0, L, length=Nx)
    dx = x[2] - x[1]
    
    # Finite difference matrix
    A = -2*I + diagm(1 => ones(Nx-1), -1 => ones(Nx-1))
    A[1, :] .= 0; A[end, :] .= 0
    
    # Wave equation system
    function wave_eq!(du, u, p, t)
        du[1:Nx] = u[Nx+1:end]
        du[Nx+1:end] = (c^2/dx^2) * (A * u[1:Nx])
    end
    
    # Initial conditions
    u0 = x .* (L .- x)  # Parabolic displacement
    v0 = zeros(Nx)      # Zero velocity
    
    # Solve ODE
    prob = ODEProblem(wave_eq!, [u0; v0], tspan)
    sol = DifferentialEquations.solve(prob, Tsit5(), saveat=0.05)
    
    # Create animation
    anim = @animate for i in 1:length(sol.t)
        plot(x, sol[1:Nx, i], 
             ylim=(-0.3, 0.3), xlim=(0, L),
             linewidth=2,
             title="Vibrating String at t = $(round(sol.t[i], digits=2))s",
             xlabel="Position (m)", ylabel="Displacement (m)")
    end
    
    gif(anim, "animations/string_vibration.gif", fps=20)
    return sol, x
end

# Run animation
sol, x = animate_vibrating_string()
