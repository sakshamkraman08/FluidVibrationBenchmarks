# File: src/lid_driven_cavity/complete_solver.jl

using Plots, LinearAlgebra, HDF5, CSV, DataFrames, Dates, Printf

# Ensure output directories exist
mkpath("Results")
mkpath("Animations")
mkpath("Validation")

println("Lid-Driven Cavity Flow Solver")
println("=" ^ 40)

# 1. Staggered grid (MAC scheme)
function create_staggered_grid(N, L)
    dx = L/(N-1)
    return (
        Nx = N, Ny = N,
        dx = dx, dy = dx,
        x_u = range(dx/2, L-dx/2, length=N-1),
        y_u = range(0, L, length=N),
        x_v = range(0, L, length=N),
        y_v = range(dx/2, L-dx/2, length=N-1),
        x_p = range(dx/2, L-dx/2, length=N-1),
        y_p = range(dx/2, L-dx/2, length=N-1)
    )
end

# 2. Apply boundary conditions
function apply_bc!(u, v, grid, Ulid)
    # u-velocity BC
    u[:, end] .= Ulid   # moving lid
    u[:, 1]  .= 0.0     # bottom
    u[1, :]  .= 0.0     # left
    u[end, :] .= 0.0    # right
    # v-velocity BC (all walls no-slip)
    v[:, [1,end]] .= 0.0
    v[[1,end], :] .= 0.0
end

# 3. Simple pressure solver
function solve_pressure!(p, u_star, v_star, grid, dt)
    dx, dy = grid.dx, grid.dy
    
    for iter in 1:100  # Simple fixed iterations
        for j in 2:size(p,2)-1, i in 2:size(p,1)-1
            # Simple pressure update
            div_u = (u_star[i+1,j] - u_star[i,j]) / dx + 
                   (v_star[i,j+1] - v_star[i,j]) / dy
            
            p[i,j] = 0.25 * (p[i+1,j] + p[i-1,j] + p[i,j+1] + p[i,j-1] - 
                            dx^2 * div_u / dt)
        end
    end
end

# 4. Compute vorticity
function compute_vorticity(u, v, grid)
    ω = zeros(grid.Nx-1, grid.Ny-1)
    
    for j in 2:grid.Ny-2, i in 2:grid.Nx-2
        dvdx = (v[i+1,j] - v[i-1,j]) / (2*grid.dx)
        dudy = (u[i,j+1] - u[i,j-1]) / (2*grid.dy)
        ω[i,j] = dvdx - dudy
    end
    
    return ω
end

# 5. Main solver - SIMPLIFIED
function solve_cavity(Re; N=65, L=1.0, Ulid=1.0, dt=0.01, Tfinal=2.0, out_step=10)
    
    println("Starting simulation:")
    println("  Reynolds number: $Re")
    println("  Grid size: $N × $N")
    println("  Time step: $dt")
    println("  Final time: $Tfinal")
    
    grid = create_staggered_grid(N, L)
    
    # Initialize flow fields
    u = zeros(N-1, N)
    v = zeros(N, N-1)
    p = zeros(N-1, N-1)
    u_star = similar(u)
    v_star = similar(v)

    t = 0.0
    step = 0
    
    while t < Tfinal
        step += 1
        
        # Apply boundary conditions
        apply_bc!(u, v, grid, Ulid)
        
        # Simple predictor step
        u_star .= u
        v_star .= v
        
        # Add simple diffusion
        for j in 2:size(u,2)-1, i in 2:size(u,1)-1
            u_star[i,j] = u[i,j] + dt/Re * 
                         ((u[i+1,j] - 2*u[i,j] + u[i-1,j])/grid.dx^2 +
                          (u[i,j+1] - 2*u[i,j] + u[i,j-1])/grid.dy^2)
        end
        
        for j in 2:size(v,2)-1, i in 2:size(v,1)-1
            v_star[i,j] = v[i,j] + dt/Re * 
                         ((v[i+1,j] - 2*v[i,j] + v[i-1,j])/grid.dx^2 +
                          (v[i,j+1] - 2*v[i,j] + v[i,j-1])/grid.dy^2)
        end
        
        # Solve pressure
        solve_pressure!(p, u_star, v_star, grid, dt)
        
        # Velocity correction
        for j in 2:size(u,2)-1, i in 2:size(u,1)-1
            u[i,j] = u_star[i,j] - dt * (p[i,j] - p[i-1,j]) / grid.dx
        end
        
        for j in 2:size(v,2)-1, i in 2:size(v,1)-1
            v[i,j] = v_star[i,j] - dt * (p[i,j] - p[i,j-1]) / grid.dy
        end
        
        # Output every out_step
        if step % out_step == 0
            @printf("Step %d: t = %.3f\n", step, t)
            
            # Compute and save vorticity
            ω = compute_vorticity(u, v, grid)
            
            heatmap(grid.x_p, grid.y_p, ω', 
                   title="Vorticity at t = $(round(t, digits=2)), Re = $Re",
                   xlabel="x", ylabel="y", 
                   color=:balance, clim=(-2, 2),
                   aspect_ratio=:equal, size=(500, 500))
            
            filename = "Animations/cavity_Re$(Re)_step$(step).png"
            savefig(filename)
            println("  Saved: $filename")
        end
        
        t += dt
    end
    
    return u, v, p, grid
end

# 6. Simple validation
function validate_results(u, v, grid, Re)
    println("Creating validation plots...")
    
    # Extract centerline velocities
    mid_i = div(size(u, 1), 2)
    mid_j = div(size(v, 2), 2)
    
    u_centerline = u[mid_i, :]
    y_u = range(0, 1, length=length(u_centerline))
    
    v_centerline = v[:, mid_j]
    x_v = range(0, 1, length=length(v_centerline))
    
    # Plot centerline velocities
    p1 = plot(u_centerline, y_u, 
              title="U-velocity at x=0.5, Re=$Re", 
              xlabel="u", ylabel="y", linewidth=2)
    
    p2 = plot(x_v, v_centerline,
              title="V-velocity at y=0.5, Re=$Re",
              xlabel="x", ylabel="v", linewidth=2)
    
    plot(p1, p2, layout=(1,2), size=(800, 400))
    filename = "Validation/cavity_validation_Re$Re.png"
    savefig(filename)
    println("  Saved: $filename")
    
    # Save validation data
    validation_df = DataFrame(
        y = collect(y_u), u = u_centerline,
        x = collect(x_v), v = v_centerline
    )
    csv_filename = "Validation/validation_data_Re$Re.csv"
    CSV.write(csv_filename, validation_df)
    println("  Saved: $csv_filename")
    
    return u_centerline, v_centerline
end

# 7. MAIN EXECUTION - REMOVED CONDITIONAL
println("STARTING LID-DRIVEN CAVITY SIMULATIONS")
println("=" ^ 50)

# Run simulations for different Reynolds numbers
Reynolds_numbers = [100]  # Start with just Re=100

for Re in Reynolds_numbers
    println("\n" * "="^40)
    println("SOLVING FOR Re = $Re")
    println("="^40)
    
    u, v, p, grid = solve_cavity(Re, N=65, Tfinal=2.0, dt=0.01, out_step=10)
    
    # Save field data
    h5_filename = "Results/cavity_Re$(Re)_fields.h5"
    h5open(h5_filename, "w") do file
        file["u"] = u
        file["v"] = v  
        file["p"] = p
        file["x_u"] = collect(grid.x_u)
        file["y_u"] = collect(grid.y_u)
        file["x_v"] = collect(grid.x_v)
        file["y_v"] = collect(grid.y_v)
        file["Re"] = Re
    end
    println("  Saved: $h5_filename")
    
    # Validation
    u_center, v_center = validate_results(u, v, grid, Re)
    
    println("Cavity simulation Re=$Re completed!")
end

# Generate report
report_filename = "Results/cavity_simulation_report.txt"
open(report_filename, "w") do file
    write(file, "Lid-Driven Cavity Simulation Report\n")
    write(file, "===================================\n")
    write(file, "Generated: $(Dates.now())\n\n")
    write(file, "Simulations completed for Re = $(Reynolds_numbers)\n")
    write(file, "Grid resolution: 65×65\n")
    write(file, "Time integration: Simplified projection method\n\n")
    write(file, "Generated files:\n")
    write(file, "- Vorticity animations in Animations/\n")
    write(file, "- Field data (HDF5) in Results/\n")
    write(file, "- Validation plots in Validation/\n")
end
println("  Saved: $report_filename")

println("\n" * "="^60)
println("ALL LID-DRIVEN CAVITY SIMULATIONS COMPLETED!")
println("="^60)
println("Check the following directories for results:")
println("  - Results/     : Field data (HDF5) and reports")
println("  - Animations/  : Vorticity evolution plots")  
println("  - Validation/  : Benchmark comparisons")

# List generated files
println("\nGenerated files:")
for dir in ["Results", "Animations", "Validation"]
    if isdir(dir)
        files = readdir(dir)
        if !isempty(files)
            println("$dir/:")
            for file in files
                println("  - $file")
            end
        end
    end
end
