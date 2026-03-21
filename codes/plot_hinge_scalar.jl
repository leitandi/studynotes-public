using LinearAlgebra
using Random
Random.seed!(59246)

include("perceptrons.jl")
include("plot_utils.jl")

function generate_data(N, f::Function)
  x1 = rand(N) .- 0.5
  x2 = rand(N) .- 0.5
  X̃ = hcat(ones(N), x1, x2)
  y = f(X̃)
  return (X̃, y)
end

# Data generation
nlsum(X̃) = X̃ * [1.0, 6.0, 4.0] + 24 * X̃[:, 2] .* X̃[:, 3]
N = 100
(X̃, y) = generate_data(N, X̃ -> heaviside.(nlsum(X̃)))
X = X̃[:, 2:end]
ỹ = 2 * y .- 1

# Determine hinge θ
δ = 1.0
K = 50000
θ₀ = zeros(3)
αs = [k^(-0.5) for k = 1:K]
θ_hinge, _ = classical_perceptron(X, y, K, δ; θ_init=θ₀, αs=αs)

# Plot criteria against scalar
cs = 0.0:0.01:3.0
hinge_vals = [hinge_criterion(X̃, ỹ, c * θ_hinge, N, δ) for c in cs]
c_star = cs[argmin(hinge_vals)]

layout = base_layout(
  xaxis=axis_style(
    title="Scalar",
    zeroline=false,
    tickvals=[0, c_star],
    ticktext=["0", "c*"]
  ),
  yaxis=axis_style(
    title="Average slack",
    zeroline=false,
    rangemode="tozero",
    tickvals=[0, 1],
    ticktext=["0", "δ"]
  ),
  showlegend=true,
  hovermode=false,
  legend=legend_style(),
  shapes=[attr(
    type="line",
    xref="x",
    yref="paper",
    x0=c_star,
    x1=c_star,
    y0=0,
    y1=1,
    line=attr(color=COLOR_BLACK, width=1, dash="dot")
  )]
)

p = plot([
  scatter(
    x = cs,
    y = [hinge_criterion(X̃, ỹ, c * θ_hinge, N, 0.0) for c in cs],
    name = "δ = 0",
    hoverinfo="skip",
    line=attr(color=COLOR_PINK)
  ),
  scatter(
    x = cs,
    y = hinge_vals,
    name = "δ > 0",
    hoverinfo="skip",
    line=attr(color=COLOR_CYAN, dash="dash")
  ),
], layout)
display(p)
make_transparent!(p)
savefig(p, "figures/hinge_scalar.json")
