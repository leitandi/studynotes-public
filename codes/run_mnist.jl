using PlotlyJS, JSON3
include("data_mnist.jl")
include("perceptrons.jl")

# Data preparation
X, y = load_mnist(:train, true)

# Subsample to make n/d < 1, so regularization matters
n_train = 500
X, y = X[1:n_train, :], y[1:n_train]

X̃ = prepend_ones(X)
ỹ = 2y .- 1

X_test, y_test = load_mnist(:test, true)
X̃_test = prepend_ones(X_test)

# Training parameters
T = 10000
θ_init = zeros(size(X̃, 2))
αs = [10 / sqrt(t) for t = 1:T]
N = length(y)

λs = 10.0 .^ (-4:0.5:0)
error_rates = Float64[]

for λ in λs
  fg(θ) = hinge_regularized(X̃, ỹ, θ, λ, N)
  θ_opt, _ = subgradient_polyak(fg, T, θ_init, αs)
  push!(error_rates, error_rate(X̃_test, y_test, θ_opt))
end

# Plot error rate vs lambda
p = plot(
  scatter(x=collect(λs), y=error_rates, mode="lines+markers"),
  Layout(
    title="Error Rate vs Regularization Parameter λ",
    xaxis_title="λ",
    xaxis_type="log",
    yaxis_title="Error Rate"
  )
)
display(p)