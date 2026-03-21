using LinearAlgebra
using Random; Random.seed!(13258)
using StatsBase
include("plot_utils.jl")
include("erm.jl")

xs = -0.02:0.001:1.02
f(x) = 4x^3 - 6x^2 + 3x
h(x, θ) = θ[1] + θ[2] * x
θ₀ = [0.2, 0.6]
h_fixed(x) = h(x, θ₀)

x_data = rand(10)
y_data = f.(x_data)

layout = base_layout(
  xaxis=axis_style(title="x", range=[0, 1]),
  yaxis=axis_style(range=[0, 1.05]),
  legend=legend_style(),
  hovermode="closest",
)

plt = plot([
  scatter(
    x=xs,
    y=f.(xs),
    name="Data generating function",
    legendrank=2,
    line=attr(color=COLOR_BLACK, width=1, dash=:dot),
    hoverinfo="skip",
  ),
  scatter(
    x=xs,
    y=h_fixed.(xs),
    name="Hypothesis",
    legendrank=3,
    line=attr(color=COLOR_PINK, width=2),
    hoverinfo="skip",
  ),
  scatter(
    mode="markers",
    x=x_data,
    y=y_data,
    name="Observations",
    legendrank=1,
    marker=attr(color=COLOR_BLACK, size=8),
    hoverinfo="x+y"
  )],
  layout
)

display(plt)
make_transparent!(plt)
savefig(plt, "figures/risk.json")


# True risk calculation
R(θ) = risk(f, h, θ, (0.0, 1.0), loss_abs)
@assert isapprox(R(θ₀), 0.065; atol=1e-3)

# Empirical risk calculation
R̂(θ) = empirical_risk(x_data, y_data, h, θ, loss_abs)
R_emp = mean(abs.(y_data .- h_fixed.(x_data)))
@assert isapprox(R_emp, R̂(θ₀); atol=1e-8)

# ERM under affine hypotheses
θ_opt, _ = erm(x_data, y_data, h, θ₀, :absolute)

R̂(θ_opt)
R(θ_opt)
