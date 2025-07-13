using Plots, LinearAlgebra, HDF5, CSV, DataFrames, Dates, Printf

# Ensure output directories exist
mkpath("Results")
mkpath("Animations")
mkpath("Validation")

println("Stable Lid-Driven Cavity Flow Solver")
println("=" ^ 40)

# Create staggered grid
function create_staggered_grid(N, L)
    dx = L/(N-1)
    return (
        Nx = N, Ny = N, dx = dx, dy = dx,
        x_u = range(dx/2, L-dx/2, length=N-1),
        y_u = range(0, L, length=N),
        x_v = range(0, L, length=N),
        y_v = range(dx/2, L-dx/2, length=N-1)
    )
end

# Apply boundary conditions
function apply_bc!(u, v, grid, Ulid)
    # Moving lid (top boundary)
    u[:, end] .= Ulid
    # No-slip walls
    u[:, 1] .= 0.0    # bottom
    u[1, :] .= 0.0    # left
    u[end, :] .= 0.0  # right
    
    v[:, 1] .= 0.0    # bottom
    v[:, end] .= 0.0  # top
    v[1, :] .= 0.0    # left
    v[end, :] .= 0.0  # right
end

# Check for numerical stability
function check_stability(u, v, step)
    max_u = maximum(abs.(u))
    max_v = maximum(abs.(v))
    
    if any(isnan.(u)) || any(isinf.(u)) || any(isnan.(v)) || any(isinf.(v))
        error("NaN/Inf detected at step $step! Simulation unstable.")
    end
    
    if max_u > 100 || max_v > 100
        error("Velocities too large at step $step: max|u|=$max_u, max|v|=$max_v")
    end
    
    return max_u, max_v
end

# FIXED: Implicit diffusion solver to prevent instability
function solve_diffusion_implicit!(u, v, grid, Re, dt)
    dx = grid.dx
    N = grid.Nx
    
    # Diffusion coefficient
    alpha = dt / (Re * dx^2)
    
    # For u-velocity: solve (I - alpha*L)u_new = u_old
    for j in 2:N-1
        # Create tridiagonal system for each row
        a = fill(-alpha, N-3)  # sub-diagonal
        b = fill(1 + 4*alpha, N-2)  # main diagonal
        c = fill(-alpha, N-3)  # super-diagonal
        
        # Right hand side
        rhs = u[2:end-1, j]
        
        # Boundary conditions in RHS
        rhs[1] += alpha * u[1, j]      # left boundary
        rhs[end] += alpha * u[end, j]  # right boundary
        
        # Solve tridiagonal system
        u[2:end-1, j] = solve_tridiagonal(a, b, c, rhs)
    end
    
    # For v-velocity: similar process
    for i in 2:N-1
        a = fill(-alpha, N-3)
        b = fill(1 + 4*alpha, N-2)
        c = fill(-alpha, N-3)
        
        rhs = v[i, 2:end-1]
        rhs[1] += alpha * v[i, 1]
        rhs[end] += alpha * v[i, end]
        
        v[i, 2:end-1] = solve_tridiagonal(a, b, c, rhs)
    end
end

# Solve tridiagonal system
function solve_tridiagonal(a, b, c, d)
    n = length(d)
    c_star = zeros(n-1)
    d_star = zeros(n)
    
    # Forward sweep
    c_star[1] = c[1] / b[1]
    d_star[1] = d[1] / b[1]
    
    for i in 2:n-1
        m = b[i] - a[i-1] * c_star[i-1]
        c_star[i] = c[i] / m
        d_star[i] = (d[i] - a[i-1] * d_star[i-1]) / m
    end
    
    d_star[n] = (d[n] - a[n-1] * d_star[n-1]) / (b[n] - a[n-1] * c_star[n-1])
    
    # Back substitution
    x = zeros(n)
    x[n] = d_star[n]
    for i in n-1:-1:1
        x[i] = d_star[i] - c_star[i] * x[i+1]
    end
    
    return x
end

# Simple pressure solver
function solve_pressure!(p, u, v, grid, dt)
    dx = grid.dx
    N = grid.Nx
    
    # Gauss-Seidel iteration for pressure
    for iter in 1:20
        for j in 2:N-2, i in 2:N-2
            # Divergence of velocity
            div_u = (u[i+1,j] - u[i,j])/dx + (v[i,j+1] - v[i,j])/dx
            
            # Pressure update (Gauss-Seidel)
            p[i,j] = 0.25 * (p[i+1,j] + p[i-1,j] + p[i,j+1] + p[i,j-1] - 
                            dx^2 * div_u / dt)
        end
        
        # Apply pressure boundary conditions
        p[1, :] = p[2, :]      # left
        p[end, :] = p[end-1, :] # right
        p[:, 1] = p[:, 2]      # bottom
        p[:, end] = p[:, end-1] # top
    end
end

# Compute vorticity for visualization
function compute_vorticity(u, v, grid)
    ω = zeros(grid.Nx-1, grid.Ny-1)
    
    for j in 2:grid.Ny-2, i in 2:grid.Nx-2
        dvdx = (v[i+1,j] - v[i-1,j]) / (2*grid.dx)
        dudy = (u[i,j+1] - u[i,j-1]) / (2*grid.dy)
        ω[i,j] = dvdx - dudy
    end
    
    return ω
end

# CORRECTED: Main cavity solver with proper stability
function solve_cavity(Re; N=65, L=1.0, Ulid=1.0, Tfinal=1.0)
    println("Starting stable cavity simulation:")
    println("  Re = $Re, Grid = $N×$N, Tfinal = $Tfinal")
    
    grid = create_staggered_grid(N, L)
    
    # CRITICAL: Proper time step based on diffusion stability
    dt_diff = 0.25 * grid.dx^2 * Re  # Diffusion stability
    dt_conv = 0.5 * grid.dx / Ulid   # Convection stability
    dt = min(dt_diff, dt_conv, 0.001)  # Conservative choice
    
    println("  Using dt = $dt for stability")
    
    # Initialize fields
    u = zeros(N-1, N)
    v = zeros(N, N-1)
    p = zeros(N-1, N-1)
    
    t = 0.0
    step = 0
    output_step = max(1, Int(0.1 / dt))  # Output every 0.1 time units
    
    while t < Tfinal
        step += 1
        
        # Apply boundary conditions
        apply_bc!(u, v, grid, Ulid)
        
        # FIXED: Use implicit diffusion for stability
        solve_diffusion_implicit!(u, v, grid, Re, dt)
        
        # Apply boundary conditions after diffusion
        apply_bc!(u, v, grid, Ulid)
        
        # Solve pressure with current velocities
        solve_pressure!(p, u, v, grid, dt)
        
        # Velocity correction (projection step)
        for j in 2:N-1, i in 2:N-2
            u[i,j] -= dt * (p[i+1,j] - p[i,j]) / grid.dx
        end
        
        for j in 2:N-2, i in 2:N-1
            v[i,j] -= dt * (p[i,j+1] - p[i,j]) / grid.dy
        end
        
        # Apply boundary conditions after correction
        apply_bc!(u, v, grid, Ulid)
        
        # Check stability every 100 steps
        if step % 100 == 0
            max_u, max_v = check_stability(u, v, step)
            @printf("Step %d: t = %.4f, max|u| = %.4f, max|v| = %.4f\n", 
                    step, t, max_u, max_v)
        end
        
        # Output visualization
        if step % output_step == 0
            ω = compute_vorticity(u, v, grid)
            
            heatmap(ω', title="Vorticity at t=$(round(t,digits=2))", 
                   xlabel="x", ylabel="y",
                   color=:balance, clim=(-2, 2),
                   aspect_ratio=:equal, size=(500, 500))
            
            savefig("Animations/cavity_Re$(Re)_t$(round(t,digits=2)).png")
            println("  Saved animation frame at t=$(round(t,digits=2))")
        end
        
        t += dt
    end
    
    # Final stability check
    max_u, max_v = check_stability(u, v, step)
    println("Simulation completed successfully!")
    println("Final: max|u| = $(round(max_u,digits=4)), max|v| = $(round(max_v,digits=4))")
    
    return u, v, p, grid
end

# Run simulation
println("Running stable cavity simulation...")
u, v, p, grid = solve_cavity(100, N=65, Tfinal=1.0)

# Save results to HDF5
println("Saving results...")
h5open("Results/cavity_Re100_fields.h5", "w") do file
    file["u"] = u
    file["v"] = v
    file["p"] = p
    file["x_u"] = collect(grid.x_u)
    file["y_u"] = collect(grid.y_u)
    file["x_v"] = collect(grid.x_v)
    file["y_v"] = collect(grid.y_v)
    file["Re"] = 100
end

# Create final vorticity plot
ω = compute_vorticity(u, v, grid)
heatmap(ω', title="Final Vorticity Field, Re=100", 
       xlabel="x", ylabel="y",
       color=:balance, clim=(-2, 2),
       aspect_ratio=:equal, size=(500, 500))
savefig("Results/cavity_final_vorticity.png")

println("All results saved successfully!")
println("Files created:")
println("  - Results/cavity_Re100_fields.h5")
println("  - Results/cavity_final_vorticity.png")
println("  - Animations/cavity_Re100_t*.png")
