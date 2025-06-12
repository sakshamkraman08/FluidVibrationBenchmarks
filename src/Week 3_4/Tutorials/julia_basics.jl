"""
Julia Basics Tutorial - One Demo Per Topic
=========================================
Complete tutorial covering fundamental Julia concepts with
validated examples and outputs saved to demos folder.
"""

# Create demos directory
if !isdir("demos")
    mkdir("demos")
end

println("Julia Basics Tutorial - One Demo Per Topic")
println("=" ^ 40)

# 1. STDIN/STDOUT Operations Demo
function io_demo()
    println("\n1. Basic I/O Operations Demo:")
    
    # Output operations
    name = "Julia"
    version = 1.9
    println("Programming language: $name v$version")
    
    # Formatted output
    pi_val = π
    println("π = $(round(pi_val, digits=4))")
    
    # File I/O demonstration
    open("demos/io_demo_output.txt", "w") do file
        write(file, "Hello, World!\nThis is line 2.\nNumbers: 42, 3.14159")
    end
    
    # Read from file
    content = open("demos/io_demo_output.txt", "r") do file
        read(file, String)
    end
    
    println("File content read back:")
    println(content)
    
    # Save summary
    open("demos/julia_basics_io_results.txt", "w") do file
        write(file, "Julia Basics I/O Demo Results\n")
        write(file, "Language: $name v$version\n")
        write(file, "Pi value: $(round(pi_val, digits=4))\n")
        write(file, "File operations: Successful\n")
    end
    
    println("✓ I/O demo results saved to demos/")
end

# 2. Functions Demo
function functions_demo()
    println("\n2. Functions Demo:")
    
    # String concatenation
    greeting = "Hello, " * "World!"
    println(greeting)
    
    # Simple function
    function square(x)
        return x^2
    end
    println("square(5) = $(square(5))")
    
    # Recursive function
    function factorial(n)
        if n <= 1
            return 1
        else
            return n * factorial(n-1)
        end
    end
    println("factorial(5) = $(factorial(5))")
    
    # Anonymous function
    cube = x -> x^3
    println("cube(3) = $(cube(3))")
    
    # Save results
    open("demos/julia_basics_functions_results.txt", "w") do file
        write(file, "Functions Demo Results\n")
        write(file, greeting * "\n")
        write(file, "square(5) = " * string(square(5)) * "\n")
        write(file, "factorial(5) = " * string(factorial(5)) * "\n")
        write(file, "cube(3) = " * string(cube(3)) * "\n")
    end
    
    println("✓ Functions demo results saved to demos/")
end

# 3. Control Flow Demo
function control_flow_demo()
    println("\n3. Control Flow Demo:")
    
    # For loop
    result = ""
    for i in 1:5
        result *= string(i) * " "
    end
    println("For loop 1 to 5: " * result)
    
    # While loop
    count = 5
    while_result = ""
    while count > 0
        while_result *= string(count) * " "
        count -= 1
    end
    println("While loop countdown: " * while_result)
    
    # Nested loop with break
    println("Finding pairs that sum to 7:")
    pairs = String[]
    for i in 1:5
        for j in 1:5
            if i + j == 7
                pair_str = "($i, $j)"
                println("Found pair: $pair_str")
                push!(pairs, pair_str)
            end
        end
    end
    
    # Save results
    open("demos/julia_basics_control_flow_results.txt", "w") do file
        write(file, "Control Flow Demo Results\n")
        write(file, "For loop 1 to 5: " * result * "\n")
        write(file, "While loop countdown: " * while_result * "\n")
        write(file, "Pairs summing to 7: " * join(pairs, ", ") * "\n")
    end
    
    println("✓ Control flow demo results saved to demos/")
end

# 4. Conditionals Demo
function conditionals_demo()
    println("\n4. Conditionals Demo:")
    
    # Basic if-else function
    function classify_number(x)
        if x > 0
            return "positive"
        elseif x < 0
            return "negative"
        else
            return "zero"
        end
    end
    
    # Ternary operator
    function abs_value(x)
        return x >= 0 ? x : -x
    end
    
    # Grade classifier
    function get_grade(score)
        if score >= 90
            return "A"
        elseif score >= 80
            return "B"
        elseif score >= 70
            return "C"
        elseif score >= 60
            return "D"
        else
            return "F"
        end
    end
    
    # Test values
    test_values = [-1, 0, 1]
    test_scores = [95, 75, 55]
    
    for val in test_values
        println("classify_number($val) = " * classify_number(val))
        println("abs_value($val) = $(abs_value(val))")
    end
    
    for score in test_scores
        println("Score $score gets grade: $(get_grade(score))")
    end
    
    # Save results
    open("demos/julia_basics_conditionals_results.txt", "w") do file
        write(file, "Conditionals Demo Results\n")
        for val in test_values
            write(file, "classify_number($val) = " * classify_number(val) * "\n")
            write(file, "abs_value($val) = $(abs_value(val))\n")
        end
        for score in test_scores
            write(file, "Score $score gets grade: $(get_grade(score))\n")
        end
    end
    
    println("✓ Conditionals demo results saved to demos/")
end

# 5. Data Types Demo
function data_types_demo()
    println("\n5. Data Types Demo:")
    
    # Basic data types
    int_val = 42
    float_val = 3.14
    string_val = "Julia"
    bool_val = true
    char_val = 'A'
    
    # Collections
    array_val = [1, 2, 3]
    tuple_val = (1, "hello", 3.14)
    dict_val = Dict("key" => "value", "number" => 42)
    
    # Complex and rational numbers
    complex_val = 1 + 2im
    rational_val = 3//4
    
    println("int_val: $int_val ($(typeof(int_val)))")
    println("float_val: $float_val ($(typeof(float_val)))")
    println("string_val: $string_val ($(typeof(string_val)))")
    println("bool_val: $bool_val ($(typeof(bool_val)))")
    println("char_val: $char_val ($(typeof(char_val)))")
    println("array_val: $array_val ($(typeof(array_val)))")
    println("tuple_val: $tuple_val ($(typeof(tuple_val)))")
    println("dict_val: $dict_val ($(typeof(dict_val)))")
    println("complex_val: $complex_val ($(typeof(complex_val)))")
    println("rational_val: $rational_val ($(typeof(rational_val)))")
    
    # Type conversions
    str_to_int = parse(Int, "123")
    int_to_float = Float64(42)
    
    println("Type conversion - parse(Int, \"123\"): $str_to_int")
    println("Type conversion - Float64(42): $int_to_float")
    
    # Save results
    open("demos/julia_basics_data_types_results.txt", "w") do file
        write(file, "Data Types Demo Results\n")
        write(file, "int_val: $int_val ($(typeof(int_val)))\n")
        write(file, "float_val: $float_val ($(typeof(float_val)))\n")
        write(file, "string_val: $string_val ($(typeof(string_val)))\n")
        write(file, "bool_val: $bool_val ($(typeof(bool_val)))\n")
        write(file, "char_val: $char_val ($(typeof(char_val)))\n")
        write(file, "array_val: $array_val ($(typeof(array_val)))\n")
        write(file, "tuple_val: $tuple_val ($(typeof(tuple_val)))\n")
        write(file, "dict_val: $dict_val ($(typeof(dict_val)))\n")
        write(file, "complex_val: $complex_val ($(typeof(complex_val)))\n")
        write(file, "rational_val: $rational_val ($(typeof(rational_val)))\n")
        write(file, "str_to_int: $str_to_int\n")
        write(file, "int_to_float: $int_to_float\n")
    end
    
    println("✓ Data types demo results saved to demos/")
end

# 6. String Handling Demo
function string_handling_demo()
    println("\n6. String Handling Demo:")
    
    # String creation
    s1 = "Hello"
    s2 = "World"
    
    # String operations
    concat = s1 * ", " * s2 * "!"
    interp = "$s1, $s2!"
    
    println("Concatenation: $concat")
    println("Interpolation: $interp")
    
    # String manipulation
    sample_text = "  Julia Programming  "
    println("Original: \"$sample_text\"")
    println("Stripped: \"$(strip(sample_text))\"")
    println("Uppercase: \"$(uppercase(strip(sample_text)))\"")
    println("Lowercase: \"$(lowercase(strip(sample_text)))\"")
    
    # String searching and replacement
    text = "The quick brown fox"
    println("Contains 'fox': $(contains(text, "fox"))")
    println("Replace 'fox' with 'cat': $(replace(text, "fox" => "cat"))")
    
    # String splitting
    words = split(text, " ")
    println("Words: $words")
    println("Word count: $(length(words))")
    
    # Save results
    open("demos/julia_basics_string_handling_results.txt", "w") do file
        write(file, "String Handling Demo Results\n")
        write(file, "Concatenation: $concat\n")
        write(file, "Interpolation: $interp\n")
        write(file, "Original: \"$sample_text\"\n")
        write(file, "Stripped: \"$(strip(sample_text))\"\n")
        write(file, "Uppercase: \"$(uppercase(strip(sample_text)))\"\n")
        write(file, "Lowercase: \"$(lowercase(strip(sample_text)))\"\n")
        write(file, "Contains 'fox': $(contains(text, "fox"))\n")
        write(file, "Replace result: $(replace(text, "fox" => "cat"))\n")
        write(file, "Words: $words\n")
        write(file, "Word count: $(length(words))\n")
    end
    
    println("✓ String handling demo results saved to demos/")
end

# Run all demos
io_demo()
functions_demo()
control_flow_demo()
conditionals_demo()
data_types_demo()
string_handling_demo()

# Create comprehensive summary
using Dates
open("demos/julia_basics_summary.txt", "w") do file
    write(file, "Julia Basics Tutorial Summary\n")
    write(file, "============================\n")
    write(file, "Date: $(Dates.now())\n\n")
    write(file, "All tutorial sections completed successfully:\n")
    write(file, "✓ Input/Output Operations\n")
    write(file, "✓ Functions\n")
    write(file, "✓ Control Flow\n")
    write(file, "✓ Conditionals\n")
    write(file, "✓ Data Types\n")
    write(file, "✓ String Handling\n\n")
    write(file, "All results saved to demos/ folder\n")
end

println("\n" * "=" ^ 50)
println("Julia Basics Tutorial completed successfully!")
println("All demo results saved to demos/ folder")

# List files created
demo_files = readdir("demos")
println("\nFiles created in demos/ folder:")
for file in demo_files
    println("  - $file")
end
