using Plots

# Data for performance comparison
methods = ["Euler", "RK4", "Tsit5"]
runtime_ms = [48.2, 22.1, 15.3]           # Runtime in milliseconds
max_error_percent = [12.7, 0.05, 0.002]   # Maximum error in percent

# Create grouped bar chart
bar(methods, [runtime_ms max_error_percent],
    bar_position = :dodge,
    legend = :topright,
    title = "Performance comparison of numerical methods",
    xlabel = "Method",
    ylabel = "Value",
    label = ["Runtime (ms)" "Max Error (%)"],
    lw = 0.5)

# Save the chart
!isdir("../FluidVibrationBenchmarks/images") && mkdir("../FluidVibrationBenchmarks/images")
savefig("../FluidVibrationBenchmarks/images/performance_chart.png")
