"""
Scientific Computing Libraries in Julia
=======================================
Tutorial on libraries for scientific computing with tiny demos for each library.
One demo per library with outputs saved to demos folder.
"""

# ALL USING STATEMENTS AT TOP LEVEL
using LinearAlgebra
using DifferentialEquations
using Plots
using DataFrames
using CSV
using Statistics
using Random
using Dates

# Create demos directory
mkpath("demos")

println("Scientific Computing Libraries Tutorial")
println("=" ^ 45)

# DEMO 1: LinearAlgebra.jl
function linear_algebra_demo()
    println("\n1. LinearAlgebra.jl Demo:")
    
    # Create a sample matrix and vector
    A = [2.0 1.0 0.0; 1.0 3.0 1.0; 0.0 1.0 2.0]
    b = [1.0, 2.0, 1.0]
    
    println("  Matrix A:")
    display(A)
    println("  Vector b: $b")
    
    # Basic linear algebra operations
    det_A = det(A)
    tr_A = tr(A)
    norm_A = norm(A)
    eigenvals = eigvals(A)
    
    # Solve linear system Ax = b
    x = A \ b
    
    # LU decomposition
    F = lu(A)
    
    results = [
        "Matrix determinant: $det_A",
        "Matrix trace: $tr_A",
        "Matrix norm: $(round(norm_A, digits=4))",
        "Eigenvalues: $(round.(eigenvals, digits=4))",
        "Solution to Ax=b: $(round.(x, digits=4))",
        "LU decomposition completed"
    ]
    
    for result in results
        println("  $result")
    end
    
    # Create eigenvalue visualization
    eigenval_plot = bar(1:length(eigenvals), real.(eigenvals),
                       title="Eigenvalues of Matrix A",
                       xlabel="Index", ylabel="Eigenvalue",
                       legend=false)
    savefig(eigenval_plot, "demos/linear_algebra_eigenvalues.png")
    
    # Save results
    open("demos/linear_algebra_demo_results.txt", "w") do file
        write(file, "LinearAlgebra.jl Demo Results\n")
        write(file, "============================\n")
        for result in results
            write(file, "$result\n")
        end
    end
    
    println("  ✓ LinearAlgebra demo results saved to demos/")
    return true
end

# DEMO 2: DifferentialEquations.jl
function differential_equations_demo()
    println("\n2. DifferentialEquations.jl Demo:")
    
    # Simple ODE: dy/dt = -y, y(0) = 1
    # Analytical solution: y(t) = e^(-t)
    f(u, p, t) = -u
    u0 = 1.0
    tspan = (0.0, 3.0)
    
    # Create and solve ODE problem
    prob = ODEProblem(f, u0, tspan)
    sol = solve(prob, Tsit5())
    
    # Evaluate at specific points
    t_eval = [0.5, 1.0, 1.5, 2.0]
    numerical_vals = [sol(t) for t in t_eval]
    analytical_vals = [exp(-t) for t in t_eval]
    errors = abs.(numerical_vals - analytical_vals)
    
    results = [
        "ODE: dy/dt = -y, y(0) = 1",
        "Analytical solution: y(t) = e^(-t)",
        "Solver: Tsit5()",
        "Time span: $tspan"
    ]
    
    for (i, t) in enumerate(t_eval)
        result = "t=$t: numerical=$(round(numerical_vals[i], digits=6)), analytical=$(round(analytical_vals[i], digits=6)), error=$(round(errors[i], digits=8))"
        results = [results; result]
        println("  $result")
    end
    
    # Create solution plot
    t_plot = 0:0.1:3
    y_numerical = [sol(t) for t in t_plot]
    y_analytical = exp.(-t_plot)
    
    ode_plot = plot(t_plot, y_numerical, label="Numerical", linewidth=2)
    plot!(ode_plot, t_plot, y_analytical, label="Analytical", 
          linestyle=:dash, linewidth=2)
    title!(ode_plot, "ODE Solution: dy/dt = -y")
    xlabel!(ode_plot, "Time t")
    ylabel!(ode_plot, "y(t)")
    savefig(ode_plot, "demos/ode_solution.png")
    
    # Save results
    open("demos/differential_equations_demo_results.txt", "w") do file
        write(file, "DifferentialEquations.jl Demo Results\n")
        write(file, "====================================\n")
        for result in results
            write(file, "$result\n")
        end
    end
    
    println("  ✓ DifferentialEquations demo results saved to demos/")
    return true
end

# DEMO 3: Plots.jl
function plots_demo()
    println("\n3. Plots.jl Demo:")
    
    # Generate sample data
    x = range(0, 2π, length=100)
    y1 = sin.(x)
    y2 = cos.(x)
    y3 = sin.(x) .* cos.(x)
    
    # Create multiple plot types
    
    # Line plot
    p1 = plot(x, y1, label="sin(x)", linewidth=2, color=:blue)
    plot!(p1, x, y2, label="cos(x)", linewidth=2, color=:red)
    title!(p1, "Trigonometric Functions")
    xlabel!(p1, "x")
    ylabel!(p1, "y")
    savefig(p1, "demos/plots_line_plot.png")
    
    # Scatter plot
    Random.seed!(42)
    x_scatter = randn(50)
    y_scatter = 2*x_scatter + randn(50)*0.5
    
    p2 = scatter(x_scatter, y_scatter, alpha=0.6, markersize=4,
                title="Random Data Scatter Plot",
                xlabel="X", ylabel="Y", legend=false)
    savefig(p2, "demos/plots_scatter_plot.png")
    
    # Surface plot
    x_surf = range(-2, 2, length=30)
    y_surf = range(-2, 2, length=30)
    z_surf = [exp(-(x^2 + y^2)) for x in x_surf, y in y_surf]
    
    p3 = surface(x_surf, y_surf, z_surf,
                title="3D Gaussian Surface",
                xlabel="X", ylabel="Y", zlabel="Z")
    savefig(p3, "demos/plots_surface_plot.png")
    
    results = [
        "Line plot created: trigonometric functions",
        "Scatter plot created: random data with correlation",
        "Surface plot created: 3D Gaussian function",
        "All plots saved as PNG files"
    ]
    
    for result in results
        println("  $result")
    end
    
    # Save results
    open("demos/plots_demo_results.txt", "w") do file
        write(file, "Plots.jl Demo Results\n")
        write(file, "===================\n")
        for result in results
            write(file, "$result\n")
        end
        write(file, "\nGenerated files:\n")
        write(file, "- plots_line_plot.png\n")
        write(file, "- plots_scatter_plot.png\n")
        write(file, "- plots_surface_plot.png\n")
    end
    
    println("  ✓ Plots demo results saved to demos/")
    return true
end

# DEMO 4: DataFrames.jl
function dataframes_demo()
    println("\n4. DataFrames.jl Demo:")
    
    # Create sample dataset
    Random.seed!(42)
    n = 100
    
    df = DataFrame(
        ID = 1:n,
        Name = ["Person_$i" for i in 1:n],
        Age = rand(18:65, n),
        Score = rand(50:100, n),
        Department = rand(["Engineering", "Science", "Mathematics", "Physics"], n),
        Salary = rand(30000:80000, n)
    )
    
    println("  Dataset created with $(nrow(df)) rows and $(ncol(df)) columns")
    println("  Columns: $(names(df))")
    
    # Basic operations
    mean_age = mean(df.Age)
    mean_score = mean(df.Score)
    mean_salary = mean(df.Salary)
    
    # Group operations
    dept_stats = combine(groupby(df, :Department),
                        :Score => mean => :Mean_Score,
                        :Age => mean => :Mean_Age,
                        nrow => :Count)
    
    # Filtering
    high_performers = filter(row -> row.Score > 80, df)
    
    results = [
        "Dataset size: $(nrow(df)) rows × $(ncol(df)) columns",
        "Mean age: $(round(mean_age, digits=1)) years",
        "Mean score: $(round(mean_score, digits=1))",
        "Mean salary: \$$(round(mean_salary, digits=0))",
        "High performers (score > 80): $(nrow(high_performers)) people",
        "Departments analyzed: $(nrow(dept_stats))"
    ]
    
    for result in results
        println("  $result")
    end
    
    println("  Department statistics:")
    println(dept_stats)
    
    # Save datasets
    CSV.write("demos/dataframes_main_dataset.csv", df)
    CSV.write("demos/dataframes_department_stats.csv", dept_stats)
    CSV.write("demos/dataframes_high_performers.csv", high_performers)
    
    # Save results
    open("demos/dataframes_demo_results.txt", "w") do file
        write(file, "DataFrames.jl Demo Results\n")
        write(file, "=========================\n")
        for result in results
            write(file, "$result\n")
        end
        write(file, "\nGenerated files:\n")
        write(file, "- dataframes_main_dataset.csv\n")
        write(file, "- dataframes_department_stats.csv\n")
        write(file, "- dataframes_high_performers.csv\n")
    end
    
    println("  ✓ DataFrames demo results saved to demos/")
    return true
end

# DEMO 5: Statistics.jl
function statistics_demo()
    println("\n5. Statistics.jl Demo:")
    
    # Generate sample data
    Random.seed!(42)
    data1 = randn(1000)  # Normal distribution
    data2 = rand(1000) * 100  # Uniform distribution
    
    # Basic statistics
    stats_data1 = [
        ("Mean", mean(data1)),
        ("Median", median(data1)),
        ("Standard deviation", std(data1)),
        ("Variance", var(data1)),
        ("Minimum", minimum(data1)),
        ("Maximum", maximum(data1))
    ]
    
    stats_data2 = [
        ("Mean", mean(data2)),
        ("Median", median(data2)),
        ("Standard deviation", std(data2)),
        ("Variance", var(data2)),
        ("Minimum", minimum(data2)),
        ("Maximum", maximum(data2))
    ]
    
    # Correlation between datasets
    correlation = cor(data1, data2)
    
    # Quantiles
    quantiles_data1 = quantile(data1, [0.25, 0.5, 0.75])
    
    println("  Normal distribution statistics:")
    for (name, value) in stats_data1
        println("    $name: $(round(value, digits=4))")
    end
    
    println("  Uniform distribution statistics:")
    for (name, value) in stats_data2
        println("    $name: $(round(value, digits=4))")
    end
    
    println("  Correlation between datasets: $(round(correlation, digits=4))")
    println("  Quantiles (25%, 50%, 75%): $(round.(quantiles_data1, digits=4))")
    
    # Save results
    results = []
    push!(results, "Statistics.jl Demo Results")
    push!(results, "Normal distribution (n=1000):")
    for (name, value) in stats_data1
        push!(results, "  $name: $(round(value, digits=4))")
    end
    push!(results, "Uniform distribution (n=1000):")
    for (name, value) in stats_data2
        push!(results, "  $name: $(round(value, digits=4))")
    end
    push!(results, "Correlation: $(round(correlation, digits=4))")
    push!(results, "Quantiles: $(round.(quantiles_data1, digits=4))")
    
    open("demos/statistics_demo_results.txt", "w") do file
        write(file, "Statistics.jl Demo Results\n")
        write(file, "=========================\n")
        for result in results[2:end]
            write(file, "$result\n")
        end
    end
    
    println("  ✓ Statistics demo results saved to demos/")
    return true
end

# Run all library demos
println("\nRunning all scientific computing library demonstrations...")

linear_algebra_demo()
differential_equations_demo()
plots_demo()
dataframes_demo()
statistics_demo()

# Create comprehensive summary
open("demos/scientific_libraries_summary.txt", "w") do file
    write(file, "Scientific Computing Libraries Tutorial Summary\n")
    write(file, "==============================================\n")
    write(file, "Date: $(Dates.now())\n\n")
    write(file, "Libraries demonstrated with individual demos:\n")
    write(file, "1. LinearAlgebra.jl - Matrix operations, eigenvalues, linear systems\n")
    write(file, "2. DifferentialEquations.jl - ODE solving with error analysis\n")
    write(file, "3. Plots.jl - Line plots, scatter plots, 3D surface plots\n")
    write(file, "4. DataFrames.jl - Data manipulation, grouping, filtering\n")
    write(file, "5. Statistics.jl - Descriptive statistics, correlations, quantiles\n\n")
    write(file, "All results, plots, and datasets saved to demos/ folder\n")
    write(file, "Each library demo is self-contained and validates core functionality\n")
end

println("\n" * "=" ^ 50)
println("Scientific Computing Libraries Tutorial completed!")
println("All library demos completed successfully!")

# List all files created
demo_files = readdir("demos")
println("\nFiles created in demos/ folder:")
for file in demo_files
    if startswith(file, "linear_algebra") || startswith(file, "differential_equations") || 
       startswith(file, "plots_") || startswith(file, "dataframes_") || 
       startswith(file, "statistics_") || file == "scientific_libraries_summary.txt"
        println("  - $file")
    end
end
