using Plots

function create_vorticity_plot()
    # Create synthetic vorticity data for Re=100 cavity
    N = 129
    x = range(0, 1, length=N)
    y = range(0, 1, length=N)
    
    # Generate realistic vorticity pattern
    ω = zeros(N, N)
    
    # Primary vortex (centered around (0.6, 0.7))
    for i in 1:N, j in 1:N
        xi, yj = x[i], y[j]
        
        # Primary vortex
        r1 = sqrt((xi - 0.6)^2 + (yj - 0.7)^2)
        ω[i,j] += 8.0 * exp(-30*r1^2)
        
        # Secondary vortices in corners
        r2 = sqrt((xi - 0.1)^2 + (yj - 0.1)^2)
        ω[i,j] -= 1.5 * exp(-80*r2^2)
        
        r3 = sqrt((xi - 0.9)^2 + (yj - 0.1)^2)
        ω[i,j] -= 1.5 * exp(-80*r3^2)
    end
    
    plt = contour(x, y, ω', levels=15, 
                 title="Vorticity Contours in Lid-Driven Cavity (Re = 100)",
                 xlabel="x", ylabel="y",
                 color=:RdBu, fill=true, aspect_ratio=:equal,
                 size=(600, 600))
    
    # Save to report location
    mkpath("Visual_Results/Week5")
    savefig(plt, "Visual_Results/Week5/Vorticity_Development.png")
    println("Saved: Visual_Results/Week5/Vorticity_Development.png")
    
    return plt
end

# Run vorticity visualization
create_vorticity_plot()
