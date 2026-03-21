using LinearAlgebra
using Random
using Printf
include("data_mnist.jl")
include("perceptrons.jl")
include("plot_utils.jl")

function run_lambda_sweep(λs, T, seed)
  X, y = load_mnist(:train, true)
  ỹ = 2y .- 1
  X_test, y_test = load_mnist(:test, true)

  θs = Vector{Vector{Float64}}(undef, length(λs))
  errors = Vector{Float64}(undef, length(λs))

  Threads.@threads for idx in eachindex(λs)
    λ = λs[idx]
    θs[idx] = pegasos(X, ỹ, λ, T; seed=seed)
    errors[idx] = error_rate(X_test, y_test, θs[idx])
  end

  return (θs, errors)
end

λs = 10.0 .^ range(-6, 0, length=12)
(θs, errors) = run_lambda_sweep(λs, 10^7, 147)

# Tabulate the result
for idx in eachindex(λs)
  @printf("λ = %.2e, error = %5.2f%%\n", λs[idx], errors[idx] * 100)
end

# Plot the result
p = Plot(
  scatter(
    x=λs,
    y=errors .* 100,
    mode="lines+markers",
    line_color=COLOR_PINK,
    hovertemplate="λ: %{x:.2}<br>Error Rate: %{y:.2f}%<extra></extra>",
  ),
  base_layout(
    xaxis=axis_style(title="λ", axis_type="log"),
    yaxis=axis_style(title="Error Rate (%)", range=[0, 8], tickformat=".0f")
  )
)

display(p)
make_transparent!(p)
savefig(p, "figures/svm_lambda.json")

