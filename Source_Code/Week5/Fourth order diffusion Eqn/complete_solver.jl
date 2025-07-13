using Plots, LinearAlgebra, CSV, DataFrames, Dates, Printf

# Ensure output directories exist
mkpath("Visual_Results/Week5")
mkpath("Results")
mkpath("Animations")

println("Fourth-Order Diffusion Equation Solver - Report Aligned Version")
println("=" ^ 60)

# 1. Analytical solution function
function analytical_solution(x, t, D=0.1, L=1.0)
    """
    Analytical solution for fourth-order diffusion with D=0.1
    u(x,t) = sin(2πx/L) * exp(-16π⁴Dt/L⁴) + 0.5*sin(4πx/L) * exp(-256π⁴Dt/L⁴)
    """
    term1 = sin.(2π * x / L) .* exp(-16 * π^4 * D * t / L^4)
    term2 = 0.5 * sin.(4π * x / L) .* exp(-256 * π^4 * D * t / L^4)
    return term1 + term2
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
    """
    A = zeros(Nx, Nx)
    coeff = D * dt / dx^4
    
    # Interior points
    for i in 3:Nx-2
        A[i, i-2] = -coeff
        A[i, i-1] = 4 * coeff
        A[i, i]   = 1 - 6 * coeff
        A[i, i+1] = 4 * coeff
        A[i, i+2] = -coeff
    end
    
    # Boundary conditions: u = 0 at x = 0 and x = L
    A[1, 1] = 1.0
    A[2, 2] = 1.0
    A[Nx-1, Nx-1] = 1.0
    A[Nx, Nx] = 1.0
    
    return A
end

# 4. Main solver function with report parameters
function solve_fourth_order_diffusion_report()
    # Report-aligned parameters
    L = 1.0
    T = 0.04  # Intermediate time
    D = 0.1   # Reduced diffusion coefficient
    Nx = 101
    Nt = 400  # Adjusted for new T
    
    println("Problem Parameters (Report Aligned):")
    println("  Domain length: $L")
    println("  Final time: $T")
    println("  Grid points: $Nx")
    println("  Time steps: $Nt")
    println("  Diffusion coefficient: $D")
    
    # Discretization
    dx = L / (Nx - 1)
    dt = T / Nt
    x = range(0, L, length=Nx)
    
    println("  Δx = $(round(dx, digits=4))")
    println("  Δt = $(round(dt, digits=6))")
    
    # Initial condition
    u = initial_condition(x, L)
    u_initial = copy(u)
    
    # Build system matrix
    A = build_fourth_order_matrix(Nx, dx, D, dt)
    
    # Time stepping
    println("\nTime Integration:")
    for n in 1:Nt
        current_time = n * dt
        
        # Apply boundary conditions
        u[1] = 0.0
        u[2] = 0.0
        u[Nx-1] = 0.0
        u[Nx] = 0.0
        
        # Solve linear system
        u = A \ u
        
        # Progress output
        if n % (Nt ÷ 4) == 0
            @printf("  t = %.4f, max|u| = %.6f\n", current_time, maximum(abs.(u)))
        end
    end
    
    return u, x, u_initial, T, D, L
end

# 5. Create report-specific comparison plot
function create_report_comparison_plot(x, u_initial, u_numerical, D, t)
    """
    Generate the exact plot shown in the report
    """
    plt = plot(x, u_initial, label="Initial Condition", 
              linewidth=3, linestyle=:dash, color=:black)
    plot!(plt, x, u_numerical, label="Numerical Solution", 
          linewidth=2, color=:blue)
    
    xlabel!(plt, "x")
    ylabel!(plt, "u(x,t)")
    title!(plt, "Fourth-Order Diffusion: Numerical vs Initial Condition (t = 0.04)")
    
    # Save to report location
    savefig(plt, "Visual_Results/Week5/Diffusion_Comparison.png")
    println("  Saved: Visual_Results/Week5/Diffusion_Comparison.png")
    
    return plt
end

# 6. Create comprehensive comparison with all three curves
function create_comprehensive_comparison(x, u_initial, u_numerical, u_analytical, D, t)
    """
    Generate plot with initial, numerical, and analytical solutions
    """
    plt = plot(x, u_initial, label="Initial Condition", 
              linewidth=3, linestyle=:dash, color=:black)
    plot!(plt, x, u_numerical, label="Numerical Solution", 
          linewidth=2, color=:blue)
    plot!(plt, x, u_analytical, label="Analytical Solution", 
          linewidth=2, color=:red, linestyle=:dot)
    
    xlabel!(plt, "x")
    ylabel!(plt, "u(x,t)")
    title!(plt, "Fourth-Order Diffusion: Complete Comparison (D=0.1, t=0.04)")
    
    savefig(plt, "Results/diffusion4_complete_comparison.png")
    println("  Saved: Results/diffusion4_complete_comparison.png")
    
    return plt
end

# 7. Validation function
function validate_solution(u_final, x, u_initial, D, L, T)
    """
    Validate numerical solution against analytical
    """
    u_analytical = analytical_solution(x, T, D, L)
    
    # Error analysis
    error_l2 = sqrt(sum((u_final - u_analytical).^2) * (x[2] - x[1]))
    error_max = maximum(abs.(u_final - u_analytical))
    
    println("\nValidation Results:")
    println("  L2 error: $(round(error_l2, digits=8))")
    println("  Max error: $(round(error_max, digits=8))")
    
    # Create report comparison plot
    create_report_comparison_plot(x, u_initial, u_final, D, T)
    
    # Create comprehensive comparison
    create_comprehensive_comparison(x, u_initial, u_final, u_analytical, D, T)
    
    # Save solution data
    solution_df = DataFrame(
        x = x,
        u_initial = u_initial,
        u_numerical = u_final,
        u_analytical = u_analytical,
        error = abs.(u_final - u_analytical)
    )
    
    CSV.write("Results/diffusion4_report_solution.csv", solution_df)
    println("  Saved: Results/diffusion4_report_solution.csv")
    
    return error_l2, error_max
end

# 8. MAIN EXECUTION
println("STARTING REPORT-ALIGNED SIMULATION")
println("=" ^ 50)

# Run simulation
u_final, x, u_initial, T, D, L = solve_fourth_order_diffusion_report()

# Validation
error_l2, error_max = validate_solution(u_final, x, u_initial, D, L, T)

println("\n" * "="^60)
println("REPORT-ALIGNED SIMULATION COMPLETED!")
println("="^60)
println("Generated files:")
println("  - Visual_Results/Week5/Diffusion_Comparison.png (for report)")
println("  - Results/diffusion4_complete_comparison.png (all three curves)")
println("  - Results/diffusion4_report_solution.csv (solution data)")
