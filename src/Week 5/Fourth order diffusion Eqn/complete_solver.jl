# File: src/fourth_order_diffusion/complete_solver.jl

using Plots, LinearAlgebra, CSV, DataFrames, Dates, Printf

# Ensure output directories exist
mkpath("Results")
mkpath("Animations")
mkpath("Validation")

println("Fourth-Order Diffusion Equation Solver")
println("=" ^ 42)

# 1. Problem setup and analytical solution
function analytical_solution(x, t, D=1.0, L=1.0)
    """
    Analytical solution for fourth-order diffusion with initial condition sin(2πx/L)
    u(x,t) = sin(2πx/L) * exp(-16π⁴Dt/L⁴)
    """
    return sin.(2π * x / L) .* exp(-16 * π^4 * D * t / L^4)
end

# 2. Initial condition function
function initial_condition(x, L=1.0)
    """
    Initial condition: u(x,0) = sin(2πx/L) + 0.5*sin(4πx/L)
    """
    return sin.(2π * x / L) + 0.5 * sin.(4π * x / L)
end

# 3. Build fourth-order finite difference matrix
function build_fourth_order_matrix(Nx, dx, D, dt)
    """
    Build matrix for implicit fourth-order diffusion
    (I + D*dt*L₄)u^{n+1} = u^n
    where L₄ is the fourth-order derivative operator
    """
    A = zeros(Nx, Nx)
    
    # Fourth-order stencil: [1, -4, 6, -4, 1] / dx⁴
    coeff = D * dt / dx^4
    
    # Interior points (i = 3 to Nx-2)
    for i in 3:Nx-2
        A[i, i-2] = -coeff      # u[i-2]
        A[i, i-1] = 4 * coeff   # u[i-1]
        A[i, i]   = 1 - 6 * coeff  # u[i]
        A[i, i+1] = 4 * coeff   # u[i+1]
        A[i, i+2] = -coeff      # u[i+2]
    end
    
    # Boundary conditions: u = 0 at x = 0 and x = L
    A[1, 1] = 1.0
    A[2, 2] = 1.0
    A[Nx-1, Nx-1] = 1.0
    A[Nx, Nx] = 1.0
    
    return A
end

# 4. Main solver function
function solve_fourth_order_diffusion(; L=1.0, T=0.1, Nx=101, Nt=1000, D=1.0)
    
    println("Problem Parameters:")
    println("  Domain length: $L")
    println("  Final time: $T")
    println("  Grid points: $Nx")
    println("  Time steps: $Nt")
    println("  Diffusion coefficient: $D")
    
    # Discretization
    dx = L / (Nx - 1)
    dt = T / Nt
    x = range(0, L, length=Nx)
    
    # Check stability condition
    stability_factor = D * dt / dx^4
    println("  Stability factor: $(round(stability_factor, digits=6))")
    if stability_factor > 0.1
        println("  Warning: May be unstable! Consider reducing dt or increasing dx")
    end
    
    # Initial condition
    u = initial_condition(x, L)
    u_initial = copy(u)
    
    # Build system matrix
    A = build_fourth_order_matrix(Nx, dx, D, dt)
    
    # Storage for analysis
    times = Float64[]
    max_vals = Float64[]
    energy_vals = Float64[]
    
    # Time stepping
    println("\nTime Integration:")
    for n in 1:Nt
        current_time = n * dt
        
        # Apply boundary conditions
        u[1] = 0.0
        u[2] = 0.0
        u[Nx-1] = 0.0
        u[Nx] = 0.0
        
        # Solve linear system: A * u^{n+1} = u^n
        u = A \ u
        
        # Store analysis data
        push!(times, current_time)
        push!(max_vals, maximum(abs.(u)))
        push!(energy_vals, sum(u.^2) * dx)  # Discrete L2 norm
        
        # Visualization every 100 steps
        if n % (Nt ÷ 10) == 0
            # Analytical solution for comparison
            u_analytical = analytical_solution(x, current_time, D, L)
            
            p = plot(x, u_initial, label="Initial", linestyle=:dash, 
                    title="Fourth-Order Diffusion at t=$(round(current_time, digits=4))",
                    xlabel="x", ylabel="u(x,t)", linewidth=2, size=(600, 400))
            plot!(p, x, u, label="Numerical t=$(round(current_time, digits=4))", 
                  linewidth=2, color=:blue)
            plot!(p, x, u_analytical, label="Analytical", 
                  linewidth=2, color=:red, linestyle=:dot)
            ylims!(p, (-1.2, 1.2))
            
            filename = "Animations/diffusion4_t$(round(current_time, digits=4)).png"
            savefig(filename)
            println("  Saved: $filename")
        end
        
        # Progress output
        if n % (Nt ÷ 5) == 0
            @printf("  t = %.4f, max|u| = %.6f, energy = %.6f\n", 
                    current_time, maximum(abs.(u)), energy_vals[end])
        end
    end
    
    return u, x, times, max_vals, energy_vals, u_initial
end

# 5. Validation and analysis
function validate_and_analyze(u_final, x, times, max_vals, energy_vals, u_initial, D=1.0, L=1.0, T=0.1)
    
    println("\nValidation and Analysis:")
    
    # Final analytical solution
    u_analytical_final = analytical_solution(x, T, D, L)
    
    # Error analysis
    error_l2 = sqrt(sum((u_final - u_analytical_final).^2) * (x[2] - x[1]))
    error_max = maximum(abs.(u_final - u_analytical_final))
    
    println("  L2 error: $(round(error_l2, digits=8))")
    println("  Max error: $(round(error_max, digits=8))")
    
    # 1. Final comparison plot
    final_plot = plot(x, u_initial, label="Initial Condition", 
                     linewidth=3, linestyle=:dash, color=:black)
    plot!(final_plot, x, u_final, label="Numerical Final", 
          linewidth=3, color=:blue)
    plot!(final_plot, x, u_analytical_final, label="Analytical Final", 
          linewidth=3, color=:red, linestyle=:dot)
    title!(final_plot, "Fourth-Order Diffusion: Initial vs Final (T=$T)")
    xlabel!(final_plot, "x")
    ylabel!(final_plot, "u(x,t)")
    
    filename1 = "Results/diffusion4_comparison.png"
    savefig(final_plot, filename1)
    println("  Saved: $filename1")
    
    # 2. Decay analysis plot
    decay_plot = plot(times, max_vals, yscale=:log10, 
                     title="Solution Decay Analysis", xlabel="Time", ylabel="max|u|",
                     linewidth=2, label="Numerical", color=:blue)
    
    # Theoretical decay rate for leading mode
    theoretical_decay = maximum(abs.(u_initial)) * exp.(-16*π^4*D .* times / L^4)
    plot!(decay_plot, times, theoretical_decay, label="Theoretical", 
          linestyle=:dash, linewidth=2, color=:red)
    
    filename2 = "Results/diffusion4_decay.png"
    savefig(decay_plot, filename2)
    println("  Saved: $filename2")
    
    # 3. Energy evolution plot
    energy_plot = plot(times, energy_vals, yscale=:log10,
                      title="Energy Evolution", xlabel="Time", ylabel="Energy",
                      linewidth=2, label="Numerical Energy", color=:green)
    
    filename3 = "Results/diffusion4_energy.png"
    savefig(energy_plot, filename3)
    println("  Saved: $filename3")
    
    # 4. Save solution data
    solution_df = DataFrame(
        x = x,
        u_initial = u_initial,
        u_final_numerical = u_final,
        u_final_analytical = u_analytical_final,
        error = abs.(u_final - u_analytical_final)
    )
    
    csv_filename = "Results/diffusion4_solution.csv"
    CSV.write(csv_filename, solution_df)
    println("  Saved: $csv_filename")
    
    # 5. Save time evolution data
    time_df = DataFrame(
        time = times,
        max_amplitude = max_vals,
        energy = energy_vals,
        theoretical_decay = theoretical_decay
    )
    
    time_csv = "Results/diffusion4_time_evolution.csv"
    CSV.write(time_csv, time_df)
    println("  Saved: $time_csv")
    
    return error_l2, error_max
end

# 6. Generate comprehensive report
function generate_report(error_l2, error_max, D, L, T, Nx, Nt)
    
    report_filename = "Results/diffusion4_simulation_report.txt"
    
    open(report_filename, "w") do file
        write(file, "Fourth-Order Diffusion Equation Simulation Report\n")
        write(file, "================================================\n")
        write(file, "Generated: $(Dates.now())\n\n")
        
        write(file, "PROBLEM DESCRIPTION\n")
        write(file, "Equation: ∂u/∂t = -D ∂⁴u/∂x⁴\n")
        write(file, "Domain: x ∈ [0, $L]\n")
        write(file, "Time: t ∈ [0, $T]\n")
        write(file, "Boundary Conditions: u(0,t) = u(L,t) = 0\n")
        write(file, "Initial Condition: u(x,0) = sin(2πx/L) + 0.5sin(4πx/L)\n\n")
        
        write(file, "NUMERICAL METHOD\n")
        write(file, "Scheme: Implicit backward Euler\n")
        write(file, "Spatial discretization: Fourth-order central differences\n")
        write(file, "Grid points: $Nx\n")
        write(file, "Time steps: $Nt\n")
        write(file, "Diffusion coefficient: $D\n\n")
        
        write(file, "VALIDATION RESULTS\n")
        write(file, "L2 error: $(round(error_l2, digits=8))\n")
        write(file, "Maximum error: $(round(error_max, digits=8))\n")
        write(file, "Theoretical decay rate: 16π⁴D/L⁴ = $(round(16*π^4*D/L^4, digits=4))\n\n")
        
        write(file, "GENERATED FILES\n")
        write(file, "Animation frames: Animations/diffusion4_t*.png\n")
        write(file, "Comparison plot: Results/diffusion4_comparison.png\n")
        write(file, "Decay analysis: Results/diffusion4_decay.png\n")
        write(file, "Energy evolution: Results/diffusion4_energy.png\n")
        write(file, "Solution data: Results/diffusion4_solution.csv\n")
        write(file, "Time evolution: Results/diffusion4_time_evolution.csv\n")
    end
    
    println("  Saved: $report_filename")
end

# 7. MAIN EXECUTION
println("STARTING FOURTH-ORDER DIFFUSION SIMULATION")
println("=" ^ 50)

# Run simulation
u_final, x, times, max_vals, energy_vals, u_initial = solve_fourth_order_diffusion(
    L=1.0, T=0.1, Nx=101, Nt=1000, D=1.0
)

# Validation and analysis
error_l2, error_max = validate_and_analyze(
    u_final, x, times, max_vals, energy_vals, u_initial, 1.0, 1.0, 0.1
)

# Generate comprehensive report
generate_report(error_l2, error_max, 1.0, 1.0, 0.1, 101, 1000)

println("\n" * "="^60)
println("FOURTH-ORDER DIFFUSION SIMULATION COMPLETED!")
println("="^60)
println("Check the following directories for results:")
println("  - Results/     : Solution data, plots, and report")
println("  - Animations/  : Time evolution frames")  
println("  - Validation/  : (Not used for this problem)")

# List generated files
println("\nGenerated files:")
for dir in ["Results", "Animations"]
    if isdir(dir)
        files = readdir(dir)
        if !isempty(files)
            println("$dir/:")
            for file in files
                if startswith(file, "diffusion4")
                    println("  - $file")
                end
            end
        end
    end
end

println("\nSimulation completed successfully!")
