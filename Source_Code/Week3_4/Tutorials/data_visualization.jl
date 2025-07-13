"""
Data Analysis and Postprocessing, Graphing and GUI Tools in Julia
================================================================
Comprehensive demo covering data analysis, visualization, and GUI tools.
All outputs saved to demos folder.
"""

using DataFrames
using CSV
using Statistics
using Plots
using Random
using Dates

# Create demos directory
mkpath("demos")

println("Data Analysis and Visualization Tutorial")
println("=" ^ 45)

Random.seed!(42)

# DEMO: Comprehensive Data Analysis and Visualization
function data_analysis_visualization_demo()
    println("\n1. Data Analysis and Visualization Demo:")
    results = []
    
    # === DATA GENERATION ===
    n_samples = 500
    
    # Generate experimental dataset
    Temperature = randn(n_samples) * 5 .+ 25
    Pressure = randn(n_samples) * 5000 .+ 101325
    Humidity = rand(n_samples) * 100
    Material = rand(["Steel", "Aluminum", "Titanium"], n_samples)
    
    # FIXED: Initialize arrays with correct size
    Frequency = Float64[]
    Damping = Float64[]
    
    # Calculate dependent variables based on physics
    for i in 1:n_samples
        base_freq = 25 + 0.1*Temperature[i] - 0.00001*Pressure[i]
        
        if Material[i] == "Steel"
            freq = base_freq * 1.0
            damping = 0.01 + 0.0001*Humidity[i]
        elseif Material[i] == "Aluminum"
            freq = base_freq * 0.85
            damping = 0.015 + 0.00015*Humidity[i]
        else  # Titanium
            freq = base_freq * 1.1
            damping = 0.008 + 0.00012*Humidity[i]
        end
        
        # Add noise
        push!(Frequency, freq + randn() * 0.5)
        push!(Damping, damping + randn() * 0.001)
    end
    
    # FIXED: Create DataFrame after all arrays are populated
    df = DataFrame(
        Temperature = Temperature,
        Pressure = Pressure,
        Humidity = Humidity,
        Material = Material,
        Frequency = Frequency,
        Damping = Damping
    )
    
    dataset_info = "Dataset created: $(nrow(df)) samples × $(ncol(df)) variables"
    println("  $dataset_info")
    push!(results, dataset_info)
    
    # === DATA ANALYSIS ===
    
    # Basic statistics
    stats_summary = describe(df, :mean, :std, :min, :max)
    
    # Group analysis by material
    material_stats = combine(groupby(df, :Material),
                           :Frequency => mean => :Mean_Freq,
                           :Frequency => std => :Std_Freq,
                           :Damping => mean => :Mean_Damping,
                           :Temperature => mean => :Mean_Temp,
                           nrow => :Count)
    
    analysis_info = "Material groups analyzed: $(nrow(material_stats))"
    println("  $analysis_info")
    push!(results, analysis_info)
    
    # Correlation analysis
    numeric_cols = [:Temperature, :Pressure, :Humidity, :Frequency, :Damping]
    corr_matrix = cor(Matrix(df[:, numeric_cols]))
    
    # Find strongest correlation with frequency
    freq_idx = findfirst(==(:Frequency), numeric_cols)
    freq_correlations = [(var, corr_matrix[i, freq_idx]) for (i, var) in enumerate(numeric_cols) if var != :Frequency]
    sort!(freq_correlations, by=x->abs(x[2]), rev=true)
    
    corr_info = "Strongest correlation with frequency: $(freq_correlations[1][1]) (r = $(round(freq_correlations[1][2], digits=3)))"
    println("  $corr_info")
    push!(results, corr_info)
    
    # Outlier detection
    Q1 = quantile(df.Frequency, 0.25)
    Q3 = quantile(df.Frequency, 0.75)
    IQR = Q3 - Q1
    outliers = (df.Frequency .< Q1 - 1.5*IQR) .| (df.Frequency .> Q3 + 1.5*IQR)
    n_outliers = sum(outliers)
    
    outlier_info = "Outliers detected: $(n_outliers) ($(round(n_outliers/nrow(df)*100, digits=1))%)"
    println("  $outlier_info")
    push!(results, outlier_info)
    
    # === GRAPHING AND VISUALIZATION ===
    
    # 1. Scatter plot: Temperature vs Frequency by Material
    material_colors = Dict("Steel"=>:red, "Aluminum"=>:blue, "Titanium"=>:green)
    
    p1 = plot(title="Temperature vs Frequency by Material",
              xlabel="Temperature (°C)", ylabel="Frequency (Hz)")
    
    for material in unique(df.Material)
        mask = df.Material .== material
        scatter!(p1, df.Temperature[mask], df.Frequency[mask],
                 label=material, color=material_colors[material], 
                 alpha=0.6, markersize=3)
    end
    savefig(p1, "demos/data_viz_scatter_plot.png")
    
    # 2. Histogram: Frequency distribution by Material
    p2 = plot(title="Frequency Distribution by Material",
              xlabel="Frequency (Hz)", ylabel="Count")
    
    for material in unique(df.Material)
        data = df[df.Material .== material, :Frequency]
        histogram!(p2, data, alpha=0.6, label=material, 
                  color=material_colors[material], bins=15)
    end
    savefig(p2, "demos/data_viz_histogram.png")
    
    # 3. Correlation heatmap
    p3 = heatmap(corr_matrix,
                 xticks=(1:length(numeric_cols), string.(numeric_cols)),
                 yticks=(1:length(numeric_cols), string.(numeric_cols)),
                 title="Correlation Matrix",
                 color=:RdBu, aspect_ratio=:equal)
    
    # Add correlation values as annotations
    for i in 1:length(numeric_cols)
        for j in 1:length(numeric_cols)
            annotate!(p3, j, i, text(string(round(corr_matrix[i,j], digits=2)), 8, :white))
        end
    end
    savefig(p3, "demos/data_viz_correlation_heatmap.png")
    
    # 4. Multi-panel dashboard
    p4a = histogram(df.Frequency, bins=20, alpha=0.7, title="Frequency Distribution", legend=false)
    p4b = histogram(df.Damping, bins=20, alpha=0.7, title="Damping Distribution", legend=false)
    p4c = scatter(df.Pressure./1000, df.Frequency, alpha=0.5, ms=2, title="Pressure vs Frequency", legend=false)
    p4d = scatter(df.Humidity, df.Damping, alpha=0.5, ms=2, title="Humidity vs Damping", legend=false)
    
    p4 = plot(p4a, p4b, p4c, p4d, layout=(2,2), size=(800, 600))
    savefig(p4, "demos/data_viz_dashboard.png")
    
    viz_info = "Generated 4 visualization types: scatter, histogram, heatmap, dashboard"
    println("  $viz_info")
    push!(results, viz_info)
    
    # === DATA POSTPROCESSING ===
    
    # Filter high-performance materials
    high_freq_threshold = quantile(df.Frequency, 0.75)
    low_damping_threshold = quantile(df.Damping, 0.25)
    
    high_performance = df[(df.Frequency .> high_freq_threshold) .& 
                         (df.Damping .< low_damping_threshold), :]
    
    # Temperature range analysis
    temp_ranges = [(15, 20), (20, 25), (25, 30), (30, 35)]
    temp_analysis = DataFrame(
        Range = String[],
        Count = Int[],
        Mean_Frequency = Float64[],
        Std_Frequency = Float64[]
    )
    
    for (low, high) in temp_ranges
        subset = df[(df.Temperature .>= low) .& (df.Temperature .< high), :]
        if nrow(subset) > 0
            push!(temp_analysis, (
                "$(low)-$(high)°C",
                nrow(subset),
                mean(subset.Frequency),
                std(subset.Frequency)
            ))
        end
    end
    
    postprocess_info = "Postprocessing: $(nrow(high_performance)) high-performance samples identified"
    println("  $postprocess_info")
    push!(results, postprocess_info)
    
    # === GUI SIMULATION (Text-based Interactive Demo) ===
    
    # Simulate interactive filtering
    println("  GUI Simulation - Interactive Material Filter:")
    
    gui_results = String[]
    for material in unique(df.Material)
        filtered_data = df[df.Material .== material, :]
        mean_freq = mean(filtered_data.Frequency)
        count = nrow(filtered_data)
        
        gui_result = "    $material: $count samples, mean frequency = $(round(mean_freq, digits=2)) Hz"
        println(gui_result)
        push!(gui_results, gui_result)
    end
    
    gui_info = "GUI simulation completed: interactive material filtering demonstrated"
    println("  $gui_info")
    push!(results, gui_info)
    
    # === SAVE ALL DATA AND RESULTS ===
    
    # Save datasets
    CSV.write("demos/data_viz_main_dataset.csv", df)
    CSV.write("demos/data_viz_material_stats.csv", material_stats)
    CSV.write("demos/data_viz_high_performance.csv", high_performance)
    CSV.write("demos/data_viz_temperature_analysis.csv", temp_analysis)
    
    # Save correlation matrix
    corr_df = DataFrame(corr_matrix, Symbol.(numeric_cols))
    corr_df.Variable = string.(numeric_cols)
    CSV.write("demos/data_viz_correlation_matrix.csv", corr_df)
    
    # Save comprehensive results
    open("demos/data_viz_analysis_results.txt", "w") do file
        write(file, "Data Analysis and Visualization Demo Results\n")
        write(file, "===========================================\n")
        write(file, "Date: $(Dates.now())\n\n")
        
        write(file, "Dataset Information:\n")
        for result in results
            write(file, "$result\n")
        end
        
        write(file, "\nMaterial Statistics:\n")
        for row in eachrow(material_stats)
            write(file, "$(row.Material): $(row.Count) samples, mean freq = $(round(row.Mean_Freq, digits=2)) Hz\n")
        end
        
        write(file, "\nCorrelation Analysis:\n")
        for (var, corr) in freq_correlations
            write(file, "$var correlation with frequency: $(round(corr, digits=3))\n")
        end
        
        write(file, "\nGUI Simulation Results:\n")
        for gui_result in gui_results
            write(file, "$gui_result\n")
        end
        
        write(file, "\nGenerated Files:\n")
        write(file, "- data_viz_scatter_plot.png (temperature vs frequency by material)\n")
        write(file, "- data_viz_histogram.png (frequency distribution by material)\n")
        write(file, "- data_viz_correlation_heatmap.png (correlation matrix)\n")
        write(file, "- data_viz_dashboard.png (multi-panel overview)\n")
        write(file, "- data_viz_main_dataset.csv (complete dataset)\n")
        write(file, "- data_viz_material_stats.csv (material group statistics)\n")
        write(file, "- data_viz_high_performance.csv (filtered high-performance data)\n")
        write(file, "- data_viz_temperature_analysis.csv (temperature range analysis)\n")
        write(file, "- data_viz_correlation_matrix.csv (correlation data)\n")
    end
    
    println("  ✓ All data analysis and visualization results saved to demos/")
    
    return nrow(df), nrow(high_performance)
end

# Run the comprehensive demo
println("\nRunning comprehensive data analysis and visualization demonstration...")

total_samples, high_perf_samples = data_analysis_visualization_demo()

# Create summary
open("demos/data_visualization_summary.txt", "w") do file
    write(file, "Data Analysis and Visualization Tutorial Summary\n")
    write(file, "===============================================\n")
    write(file, "Date: $(Dates.now())\n\n")
    write(file, "Comprehensive Demo Completed:\n")
    write(file, "✓ Data Generation - Physics-based synthetic dataset\n")
    write(file, "✓ Statistical Analysis - Descriptive stats, correlations, outliers\n")
    write(file, "✓ Data Visualization - 4 plot types with multiple panels\n")
    write(file, "✓ Data Postprocessing - Filtering, grouping, range analysis\n")
    write(file, "✓ GUI Simulation - Interactive material filtering demonstration\n\n")
    write(file, "Dataset Summary:\n")
    write(file, "- Total samples: $total_samples\n")
    write(file, "- High-performance samples: $high_perf_samples\n")
    write(file, "- Materials analyzed: 3 (Steel, Aluminum, Titanium)\n")
    write(file, "- Variables: 6 (Temperature, Pressure, Humidity, Material, Frequency, Damping)\n\n")
    write(file, "Tools Demonstrated:\n")
    write(file, "- DataFrames.jl for data manipulation\n")
    write(file, "- Statistics.jl for statistical analysis\n")
    write(file, "- Plots.jl for comprehensive visualization\n")
    write(file, "- CSV.jl for data import/export\n")
    write(file, "- Interactive filtering simulation\n\n")
    write(file, "All outputs saved to demos/ folder for report inclusion\n")
end

println("\n" * "=" ^ 50)
println("Data Analysis and Visualization Tutorial completed!")
println("Dataset: $total_samples samples, $high_perf_samples high-performance materials identified")

# List all data visualization files created
demo_files = readdir("demos")
data_viz_files = filter(f -> startswith(f, "data_viz"), demo_files)

println("\nData visualization files created in Visual_Results/Week3_4/demos/ folder:")
for file in data_viz_files
    println("  - $file")
end

println("\nDemo completed successfully!")
