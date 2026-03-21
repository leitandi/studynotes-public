using LinearAlgebra
using Random
using Printf
include("data_mnist.jl")
include("perceptrons.jl")
include("plot_utils.jl")

function run_lambda_sweep(λs, T, seed, kernel)
	X, y = load_mnist(:train, true)
	ỹ = 2y .- 1
	X_test, y_test = load_mnist(:test, true)
	G = gram_matrix(X, kernel)
	K = cross_gram_matrix(X, X_test, kernel)

	αs = Vector{Vector{Float64}}(undef, length(λs))
	errors = Vector{Float64}(undef, length(λs))

	Threads.@threads for idx in eachindex(λs)
		λ = λs[idx]
		αs[idx] = pegasos_kernel(X, ỹ, λ, T, G; seed = seed)
		errors[idx] = error_rate_kernel(K, ỹ, y_test, αs[idx])
	end

	return (αs, errors)
end

λs = 10.0 .^ range(-6, 4, length = 11)
N = 11791
T = 20 * N
seed = 147

kernel_quadratic(x, y) = polynomial_kernel(x, y, 1, 2)
kernel_cubic(x, y) = polynomial_kernel(x, y, 1, 3)
kernel_quartic(x, y) = polynomial_kernel(x, y, 1, 4)
kernel_rbf(x, y) = rbf_kernel(x, y, 0.1)

kernels = [kernel_quadratic, kernel_cubic, kernel_quartic, kernel_rbf]
kernel_names = ["Quadratic", "Cubic", "Quartic", "RBF"]
colors = [COLOR_PINK, COLOR_CYAN, COLOR_ORANGE, COLOR_GREEN]
dash_styles = ["solid", "dash", "dot", "dashdot"]
marker_symbols = ["circle", "square", "diamond", "triangle-up"]

all_errors = Vector{Vector{Float64}}(undef, length(kernels))
for k in eachindex(kernels)
	(_, all_errors[k]) = run_lambda_sweep(λs, T, seed, kernels[k])
end

# Plot the result
traces = [
	scatter(
		x = λs,
		y = all_errors[k] .* 100,
		mode = "lines+markers",
		name = kernel_names[k],
		line = attr(color = colors[k], dash = dash_styles[k]),
		marker = attr(symbol = marker_symbols[k], size = 7),
		hovertemplate = "λ: %{x:.2g}<br>Error Rate: %{y:.2f}%<extra>$(kernel_names[k])</extra>",
	)
	for k in eachindex(kernels)
]

p = Plot(
	traces,
	base_layout(
		xaxis = axis_style(
      title = "λ",
      axis_type = "log",
      exponentformat = "power"),
		yaxis = axis_style(
      title = "Error Rate (%)",
      range = [0, 8],
      tickformat = ".0f"),
		legend = legend_style(x = 0.05, y = 0.95, xanchor = "left", yanchor = "top"),
		showlegend = true,
	),
)

display(p)
make_transparent!(p)
savefig(p, "figures/svm_kernel.json")