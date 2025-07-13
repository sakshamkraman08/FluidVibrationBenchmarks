"""
Symbolic Mathematics in Julia
============================
Using Symbolics.jl with one demo per example.
All outputs saved to demos folder.
"""

using Symbolics
using Dates

# Create demos directory
mkpath("demos")

println("Symbolic Mathematics Tutorial")
println("=" ^ 40)

# DEMO 1: Basic Symbolic Operations
function basic_symbolic_demo()
    println("\n1. Basic Symbolic Operations Demo:")
    results = []
    
    # Define symbolic variables
    @variables x y z t
    
    # Create expressions
    expr1 = x^2 + 2*x + 1
    expr2 = (x + 1)^2
    expr3 = sin(x)*cos(y) + exp(z)
    
    println("  expr1 = $expr1")
    println("  expr2 = $expr2")
    println("  expr3 = $expr3")
    
    push!(results, "expr1 = $expr1")
    push!(results, "expr2 = $expr2")
    push!(results, "expr3 = $expr3")
    
    # Simplification
    simplified = simplify(expr1 - expr2)
    equivalence = iszero(simplified)
    
    println("  Simplified expr1 - expr2: $simplified")
    println("  Are expr1 and expr2 equivalent? $equivalence")
    
    push!(results, "Simplified expr1 - expr2: $simplified")
    push!(results, "Are expr1 and expr2 equivalent? $equivalence")
    
    # Expansion
    expanded = expand((x + y + z)^3)
    println("  Expanded (x + y + z)^3: $expanded")
    push!(results, "Expanded (x + y + z)^3: $expanded")
    
    # Substitution
    substituted = substitute(expr1, Dict(x => 2))
    println("  Substituting x=2 in expr1: $substituted")
    push!(results, "Substituting x=2 in expr1: $substituted")
    
    # Save results
    open("demos/basic_symbolic_results.txt", "w") do file
        write(file, "Basic Symbolic Operations Results\n")
        write(file, "=================================\n")
        for result in results
            write(file, "$result\n")
        end
    end
    
    println("  ✓ Basic symbolic results saved to demos/")
    return results
end

# DEMO 2: Calculus Operations
function calculus_demo()
    println("\n2. Calculus Operations Demo:")
    results = []
    
    @variables x y t
    
    # Single variable calculus
    f = x^3 + 2*x^2 + x + 1
    f_prime = Symbolics.derivative(f, x)
    f_double_prime = Symbolics.derivative(f_prime, x)
    
    println("  Function: f(x) = $f")
    println("  First derivative: f'(x) = $f_prime")
    println("  Second derivative: f''(x) = $f_double_prime")
    
    push!(results, "Function: f(x) = $f")
    push!(results, "First derivative: f'(x) = $f_prime")
    push!(results, "Second derivative: f''(x) = $f_double_prime")
    
    # Multivariable calculus
    f2 = x^2*y + sin(x*y)
    df_dx = Symbolics.derivative(f2, x)
    df_dy = Symbolics.derivative(f2, y)
    
    println("  Multivariable function: f(x,y) = $f2")
    println("  Partial derivative ∂f/∂x = $df_dx")
    println("  Partial derivative ∂f/∂y = $df_dy")
    
    push!(results, "Multivariable function: f(x,y) = $f2")
    push!(results, "Partial derivative ∂f/∂x = $df_dx")
    push!(results, "Partial derivative ∂f/∂y = $df_dy")
    
    # Chain rule example
    u = x^2 + 1
    g = sin(u)
    dg_dx = Symbolics.derivative(g, x)
    
    println("  Chain rule: g = sin(x² + 1)")
    println("  dg/dx = $dg_dx")
    
    push!(results, "Chain rule: g = sin(x² + 1)")
    push!(results, "dg/dx = $dg_dx")
    
    # Save results
    open("demos/calculus_results.txt", "w") do file
        write(file, "Calculus Operations Results\n")
        write(file, "===========================\n")
        for result in results
            write(file, "$result\n")
        end
    end
    
    println("  ✓ Calculus results saved to demos/")
    return results
end

# DEMO 3: Mechanics Applications
function mechanics_applications()
    println("\n3. Mechanics Applications Demo:")
    results = []
    
    @variables t x L m k c omega E I rho A
    
    # Harmonic oscillator
    @variables A_coeff B_coeff
    x_t = A_coeff*cos(omega*t) + B_coeff*sin(omega*t)
    v_t = Symbolics.derivative(x_t, t)
    a_t = Symbolics.derivative(v_t, t)
    
    println("  Harmonic Oscillator:")
    println("    Position: x(t) = $x_t")
    println("    Velocity: v(t) = $v_t")
    println("    Acceleration: a(t) = $a_t")
    
    push!(results, "Harmonic Oscillator:")
    push!(results, "  Position: x(t) = $x_t")
    push!(results, "  Velocity: v(t) = $v_t")
    push!(results, "  Acceleration: a(t) = $a_t")
    
    # Equation of motion verification
    eom = m*a_t + k*x_t
    simplified_eom = simplify(eom)
    
    println("    Equation of motion ma + kx = $simplified_eom")
    push!(results, "  Equation of motion ma + kx = $simplified_eom")
    
    # Beam natural frequency
    omega_n = (π/L)^2 * sqrt(E*I/(rho*A))
    freq_hz = omega_n/(2*π)
    
    println("  Beam Natural Frequency:")
    println("    Angular frequency: ω = $omega_n")
    println("    Frequency in Hz: f = $freq_hz")
    
    push!(results, "Beam Natural Frequency:")
    push!(results, "  Angular frequency: ω = $omega_n")
    push!(results, "  Frequency in Hz: f = $freq_hz")
    
    # Wave equation
    @variables c_wave k_wave
    u_wave = A_coeff*sin(k_wave*x - omega*t)
    u_tt = Symbolics.derivative(Symbolics.derivative(u_wave, t), t)
    u_xx = Symbolics.derivative(Symbolics.derivative(u_wave, x), x)
    
    wave_eq = u_tt - c_wave^2*u_xx
    simplified_wave = simplify(wave_eq)
    
    println("  Wave Equation:")
    println("    Solution: u(x,t) = $u_wave")
    println("    ∂²u/∂t² - c²∂²u/∂x² = $simplified_wave")
    
    push!(results, "Wave Equation:")
    push!(results, "  Solution: u(x,t) = $u_wave")
    push!(results, "  ∂²u/∂t² - c²∂²u/∂x² = $simplified_wave")
    
    # Save results
    open("demos/mechanics_applications_results.txt", "w") do file
        write(file, "Mechanics Applications Results\n")
        write(file, "==============================\n")
        for result in results
            write(file, "$result\n")
        end
    end
    
    println("  ✓ Mechanics applications results saved to demos/")
    return results
end

# DEMO 4: Equation Solving
function equation_solving_demo()
    println("\n4. Equation Solving Demo:")
    results = []
    
    @variables x y a b c
    
    # Simple algebraic equations
    println("  Algebraic Equations:")
    
    # Linear equation example
    linear_eq = "2x + 3 = 7 → x = 2"
    println("    Linear: $linear_eq")
    push!(results, "Linear equation: $linear_eq")
    
    # Quadratic formula
    quadratic_formula = "ax² + bx + c = 0 → x = (-b ± √(b² - 4ac))/(2a)"
    println("    Quadratic: $quadratic_formula")
    push!(results, "Quadratic formula: $quadratic_formula")
    
    # System of equations
    system_eq = "2x + 3y = 7, x - y = 1 → x = 2, y = 1"
    println("    System: $system_eq")
    push!(results, "System of equations: $system_eq")
    
    # Trigonometric equations
    println("  Trigonometric Equations:")
    trig_eqs = [
        "sin(x) = 0 → x = nπ",
        "cos(x) = 0 → x = π/2 + nπ", 
        "tan(x) = 1 → x = π/4 + nπ"
    ]
    
    for eq in trig_eqs
        println("    $eq")
        push!(results, "Trigonometric: $eq")
    end
    
    # Differential equations
    println("  Differential Equations:")
    diff_eqs = [
        "dy/dt = -ky → y(t) = y₀e^(-kt)",
        "d²y/dt² + ω²y = 0 → y(t) = A cos(ωt) + B sin(ωt)"
    ]
    
    for eq in diff_eqs
        println("    $eq")
        push!(results, "Differential: $eq")
    end
    
    # Save results
    open("demos/equation_solving_results.txt", "w") do file
        write(file, "Equation Solving Results\n")
        write(file, "========================\n")
        for result in results
            write(file, "$result\n")
        end
    end
    
    println("  ✓ Equation solving results saved to demos/")
    return results
end

# DEMO 5: Series Expansions
function series_expansions_demo()
    println("\n5. Series Expansions Demo:")
    results = []
    
    @variables x h epsilon
    
    # Taylor series examples
    println("  Taylor Series:")
    
    taylor_series = [
        "sin(x) ≈ x - x³/6 + x⁵/120 - x⁷/5040 + ...",
        "cos(x) ≈ 1 - x²/2 + x⁴/24 - x⁶/720 + ...",
        "exp(x) ≈ 1 + x + x²/2 + x³/6 + x⁴/24 + ...",
        "ln(1+x) ≈ x - x²/2 + x³/3 - x⁴/4 + ..."
    ]
    
    for series in taylor_series
        println("    $series")
        push!(results, "Taylor series: $series")
    end
    
    # Small angle approximations
    println("  Small Angle Approximations:")
    small_angle = [
        "sin(ε) ≈ ε",
        "cos(ε) ≈ 1 - ε²/2",
        "tan(ε) ≈ ε + ε³/3"
    ]
    
    for approx in small_angle
        println("    $approx")
        push!(results, "Small angle: $approx")
    end
    
    # Finite difference formulas
    println("  Finite Difference Formulas:")
    finite_diff = [
        "Forward: (f(x+h) - f(x))/h",
        "Backward: (f(x) - f(x-h))/h",
        "Central: (f(x+h) - f(x-h))/(2h)",
        "Second derivative: (f(x+h) - 2f(x) + f(x-h))/h²"
    ]
    
    for formula in finite_diff
        println("    $formula")
        push!(results, "Finite difference: $formula")
    end
    
    # Save results
    open("demos/series_expansions_results.txt", "w") do file
        write(file, "Series Expansions Results\n")
        write(file, "=========================\n")
        for result in results
            write(file, "$result\n")
        end
    end
    
    println("  ✓ Series expansions results saved to demos/")
    return results
end

# Run all symbolic math demos
println("\nRunning all symbolic mathematics demonstrations...")

basic_results = basic_symbolic_demo()
calculus_results = calculus_demo()
mechanics_results = mechanics_applications()
equation_results = equation_solving_demo()
series_results = series_expansions_demo()

# Create comprehensive summary
open("demos/symbolic_math_summary.txt", "w") do file
    write(file, "Symbolic Mathematics Tutorial Summary\n")
    write(file, "====================================\n")
    write(file, "Date: $(Dates.now())\n\n")
    write(file, "Demonstrations completed:\n")
    write(file, "1. Basic Symbolic Operations - Expression creation, simplification, expansion\n")
    write(file, "2. Calculus Operations - Derivatives, partial derivatives, chain rule\n")
    write(file, "3. Mechanics Applications - Harmonic oscillator, beam frequencies, wave equation\n")
    write(file, "4. Equation Solving - Algebraic, trigonometric, differential equations\n")
    write(file, "5. Series Expansions - Taylor series, small angle approximations, finite differences\n\n")
    write(file, "Total results: $(length(basic_results) + length(calculus_results) + length(mechanics_results) + length(equation_results) + length(series_results))\n")
    write(file, "\nGenerated files:\n")
    write(file, "- basic_symbolic_results.txt\n")
    write(file, "- calculus_results.txt\n")
    write(file, "- mechanics_applications_results.txt\n")
    write(file, "- equation_solving_results.txt\n")
    write(file, "- series_expansions_results.txt\n")
end

println("\n" * "=" ^ 50)
println("Symbolic Mathematics Tutorial completed!")
println("All results saved to demos/ folder")

# List all files created
demo_files = readdir("demos")
symbolic_files = filter(f -> contains(f, "symbolic") || contains(f, "calculus") || 
                           contains(f, "mechanics") || contains(f, "equation") || 
                           contains(f, "series"), demo_files)

println("\nSymbolic math files created in demos/ folder:")
for file in symbolic_files
    println("  - $file")
end
