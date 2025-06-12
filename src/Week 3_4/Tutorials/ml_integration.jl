"""
Machine Learning Integration with Julia
======================================
Using Flux.jl with one comprehensive demo.
All outputs saved to demos folder.
"""

using Flux
using Random
using Statistics
using Plots
using CSV
using DataFrames
using Dates

# Create demos directory
mkpath("demos")

println("Machine Learning Integration Tutorial")
println("=" ^ 40)

Random.seed!(42)

# DEMO: Basic Neural Network for Regression
function ml_integration_demo()
    println("\n1. Machine Learning Integration Demo:")
    results = []
    
    # Generate synthetic regression data
    n_samples = 1000
    X = randn(Float32, 2, n_samples)
    # Target function: y = 2*x₁ + 3*x₂ + x₁*x₂ + noise
    y = 2*X[1,:] + 3*X[2,:] + X[1,:].*X[2,:] + 0.1*randn(Float32, n_samples)
    
    dataset_info = "Dataset: $(n_samples) samples with 2 features"
    println("  $dataset_info")
    push!(results, dataset_info)
    
    # Split data into training and testing sets
    n_train = 800
    X_train = X[:, 1:n_train]
    y_train = y[1:n_train]
    X_test = X[:, (n_train+1):end]
    y_test = y[(n_train+1):end]
    
    split_info = "Train/Test split: $n_train/$(n_samples-n_train)"
    println("  $split_info")
    push!(results, split_info)
    
    # Create neural network model
    model = Chain(
        Dense(2 => 32, relu),    # Input layer: 2 features → 32 neurons
        Dense(32 => 16, relu),   # Hidden layer: 32 → 16 neurons
        Dense(16 => 1)           # Output layer: 16 → 1 output
    )
    
    architecture_info = "Model architecture: 2 → 32 → 16 → 1 (ReLU activation)"
    println("  $architecture_info")
    push!(results, architecture_info)
    
    # Setup optimizer using new Flux API
    opt_state = Flux.setup(Adam(0.01), model)
    
    # Training loop with loss tracking
    losses = Float32[]
    epochs = 100
    
    println("  Training progress:")
    for epoch in 1:epochs
        # Use new Flux API for gradient computation
        loss_val, grads = Flux.withgradient(model) do m
            y_pred = m(X_train)
            Flux.mse(y_pred, y_train')
        end
        
        # Update model parameters
        Flux.update!(opt_state, model, grads[1])
        
        # Record loss every 20 epochs
        if epoch % 20 == 0
            push!(losses, loss_val)
            loss_info = "    Epoch $epoch: Loss = $(round(loss_val, digits=6))"
            println(loss_info)
            push!(results, loss_info)
        end
    end
    
    # Evaluate model performance
    y_pred_train = vec(model(X_train))
    y_pred_test = vec(model(X_test))
    
    # Calculate metrics
    train_mse = Flux.mse(y_pred_train, y_train)
    test_mse = Flux.mse(y_pred_test, y_test)
    
    # R² (coefficient of determination)
    train_r2 = 1 - sum((y_train - y_pred_train).^2) / sum((y_train .- mean(y_train)).^2)
    test_r2 = 1 - sum((y_test - y_pred_test).^2) / sum((y_test .- mean(y_test)).^2)
    
    # Mean Absolute Error
    train_mae = mean(abs.(y_train - y_pred_train))
    test_mae = mean(abs.(y_test - y_pred_test))
    
    performance_results = [
        "Training MSE: $(round(train_mse, digits=6))",
        "Test MSE: $(round(test_mse, digits=6))",
        "Training R²: $(round(train_r2, digits=4))",
        "Test R²: $(round(test_r2, digits=4))",
        "Training MAE: $(round(train_mae, digits=4))",
        "Test MAE: $(round(test_mae, digits=4))"
    ]
    
    println("  Model Performance:")
    for result in performance_results
        println("    $result")
        push!(results, result)
    end
    
    # Create visualizations
    
    # 1. Training curve
    epoch_points = 20:20:epochs
    training_curve = plot(epoch_points, losses,
                         title="Neural Network Training Curve",
                         xlabel="Epoch", ylabel="MSE Loss",
                         linewidth=2, legend=false,
                         color=:blue)
    savefig(training_curve, "demos/ml_training_curve.png")
    
    # 2. Predictions vs Actual values
    predictions_plot = scatter(y_test, y_pred_test,
                              title="ML Predictions vs Actual Values",
                              xlabel="Actual Values", ylabel="Predicted Values",
                              alpha=0.6, markersize=3,
                              color=:blue, label="Test Data")
    
    # Add perfect prediction line
    min_val = minimum([y_test; y_pred_test])
    max_val = maximum([y_test; y_pred_test])
    plot!(predictions_plot, [min_val, max_val], [min_val, max_val], 
          color=:red, linestyle=:dash, linewidth=2, label="Perfect Prediction")
    savefig(predictions_plot, "demos/ml_predictions_vs_actual.png")
    
    # 3. Residuals plot
    residuals = y_test - y_pred_test
    residuals_plot = scatter(y_pred_test, residuals,
                            title="Residuals Plot",
                            xlabel="Predicted Values", ylabel="Residuals",
                            alpha=0.6, markersize=3,
                            color=:green, legend=false)
    hline!(residuals_plot, [0], color=:red, linestyle=:dash, linewidth=2)
    savefig(residuals_plot, "demos/ml_residuals_plot.png")
    
    # Save training and test data with predictions
    train_df = DataFrame(
        Feature1 = X_train[1,:],
        Feature2 = X_train[2,:],
        Target = y_train,
        Predicted = y_pred_train,
        Error = abs.(y_train - y_pred_train)
    )
    CSV.write("demos/ml_training_data.csv", train_df)
    
    test_df = DataFrame(
        Feature1 = X_test[1,:],
        Feature2 = X_test[2,:],
        Target = y_test,
        Predicted = y_pred_test,
        Error = abs.(y_test - y_pred_test),
        Residual = y_test - y_pred_test
    )
    CSV.write("demos/ml_test_data.csv", test_df)
    
    # Save model summary and results
    open("demos/ml_integration_results.txt", "w") do file
        write(file, "Machine Learning Integration Demo Results\n")
        write(file, "========================================\n")
        write(file, "Date: $(Dates.now())\n\n")
        for result in results
            write(file, "$result\n")
        end
        write(file, "\nModel Details:\n")
        write(file, "- Framework: Flux.jl\n")
        write(file, "- Optimizer: Adam (learning rate: 0.01)\n")
        write(file, "- Loss function: Mean Squared Error\n")
        write(file, "- Activation: ReLU (hidden layers)\n")
        write(file, "- Training epochs: $epochs\n")
        write(file, "\nGenerated Files:\n")
        write(file, "- ml_training_curve.png (training progress)\n")
        write(file, "- ml_predictions_vs_actual.png (model accuracy)\n")
        write(file, "- ml_residuals_plot.png (error analysis)\n")
        write(file, "- ml_training_data.csv (training dataset with predictions)\n")
        write(file, "- ml_test_data.csv (test dataset with predictions)\n")
    end
    
    # Feature importance analysis (simple correlation-based)
    feature_correlations = [
        cor(X_test[1,:], y_test),  # Feature 1 correlation
        cor(X_test[2,:], y_test)   # Feature 2 correlation
    ]
    
    println("  Feature Analysis:")
    println("    Feature 1 correlation with target: $(round(feature_correlations[1], digits=4))")
    println("    Feature 2 correlation with target: $(round(feature_correlations[2], digits=4))")
    
    # Model complexity analysis
    total_params = sum(length, Flux.params(model))
    println("  Model Complexity:")
    println("    Total parameters: $total_params")
    
    println("  ✓ ML integration demo results saved to demos/")
    
    return test_r2, test_mse
end

# Run the ML integration demo
println("\nRunning machine learning integration demonstration...")

final_r2, final_mse = ml_integration_demo()

# Create comprehensive summary
open("demos/ml_integration_summary.txt", "w") do file
    write(file, "Machine Learning Integration Tutorial Summary\n")
    write(file, "============================================\n")
    write(file, "Date: $(Dates.now())\n\n")
    write(file, "Demonstration: Neural Network Regression\n")
    write(file, "Framework: Flux.jl with modern API\n")
    write(file, "Problem: Multi-feature regression with interaction terms\n")
    write(file, "Architecture: 2 → 32 → 16 → 1 (fully connected)\n")
    write(file, "Final Performance:\n")
    write(file, "- Test R²: $(round(final_r2, digits=4))\n")
    write(file, "- Test MSE: $(round(final_mse, digits=6))\n\n")
    write(file, "Key Features Demonstrated:\n")
    write(file, "✓ Data generation and preprocessing\n")
    write(file, "✓ Neural network architecture design\n")
    write(file, "✓ Modern Flux.jl training API\n")
    write(file, "✓ Performance evaluation metrics\n")
    write(file, "✓ Visualization of results\n")
    write(file, "✓ Data export for further analysis\n")
    write(file, "✓ Model complexity analysis\n\n")
    write(file, "All outputs saved to demos/ folder for report inclusion\n")
end

println("\n" * "=" ^ 50)
println("Machine Learning Integration Tutorial completed!")
println("Final model performance: R² = $(round(final_r2, digits=4)), MSE = $(round(final_mse, digits=6))")

# List all ML-related files created
demo_files = readdir("demos")
ml_files = filter(f -> startswith(f, "ml_"), demo_files)

println("\nML integration files created in demos/ folder:")
for file in ml_files
    println("  - $file")
end

println("\nDemo completed successfully!")
