using LinearAlgebra
using Random
Random.seed!(41234)
using StatsBase
include("plot_utils.jl")
include("erm.jl")

xs = -1.02:0.001:1.02
runge(x) = 1 / (1 + 25 * x^2)
polynomial(k, x, θ) = sum(θ[i + 1] * x^i for i in 0:k)

vc_bound_c(N, D, η) = 4 / N * (D * (log(2N / D) + 1) - log(η / 4))
vc_bound(N, D, η, R̂) = R̂ + vc_bound_c(N, D, η) / 2 * (1 + sqrt(1 + 4 * R̂ / vc_bound_c(N, D, η)))

N = 14
x_data = 2 * (rand(N) .- 0.5)
y_data = runge.(x_data)


# Plot of the data generating function and some ERM hypotheses
k1 = 4
θ̂1 = erm_polynomial_square_loss(x_data, y_data, k1)

k2 = 12
θ̂2 = erm_polynomial_square_loss(x_data, y_data, k2)

layout = base_layout(
  xaxis=axis_style(title="x", range=[-1, 1], zeroline=false),
  yaxis=axis_style(range=[0, 1.6]),
  legend=legend_style(y=0.95, yanchor="top"),
  hovermode="closest",
)

plt = plot([
  scatter(
    x=xs,
    y=runge.(xs),
    name="Data generating function",
    legendrank=2,
    line=attr(color=COLOR_BLACK, width=1, dash=:dot),
    hoverinfo="skip",
  ),
  scatter(
    x=xs,
    y=polynomial.(Ref(k1), xs, Ref(θ̂1)),
    name="ERM polynomial degree $k1",
    legendrank=3,
    line=attr(color=COLOR_PINK, width=2),
    hoverinfo="skip",
  ),
  scatter(
    x=xs,
    y=polynomial.(Ref(k2), xs, Ref(θ̂2)),
    name="ERM polynomial degree $k2",
    legendrank=4,
    line=attr(color=COLOR_CYAN, width=2, dash=:dash),
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
savefig(plt, "figures/runge.json")


# Stacked bar chart showing approximation vs estimation risk
ks = 1:12
domain = (-1.0, 1.0)
approx_risks = Float64[]
est_risks = Float64[]
for k in ks
  h_k = (x, θ) -> polynomial(k, x, θ)
  θ_erm = erm_polynomial_square_loss(x_data, y_data, k)
  θ_min = min_risk_polynomial_square_loss(runge, k, domain)
  risk_erm = risk(runge, h_k, θ_erm, domain, loss_sq)
  risk_min = risk(runge, h_k, θ_min, domain, loss_sq)
  push!(approx_risks, risk_min)
  push!(est_risks, risk_erm - risk_min)
end

risk_layout = base_layout(
  xaxis=axis_style(title="Polynomial degree k", dtick=1),
  yaxis=axis_style(title="Risk", rangemode="tozero"),
  legend=legend_style(x=0.05, y=0.95, xanchor="left", yanchor="top"),
  barmode="stack",
)

plt_risk = plot([
  bar(x=ks, y=approx_risks, name="Approximation risk", marker=attr(color=COLOR_PINK),
    hovertemplate="k = %{x}<br>Approximation risk = %{y:.4f}<extra></extra>"),
  bar(x=ks, y=est_risks, name="Estimation risk", marker=attr(color=COLOR_CYAN),
    hovertemplate="k = %{x}<br>Estimation risk = %{y:.4f}<extra></extra>")
], risk_layout)
display(plt_risk)
make_transparent!(plt_risk)
savefig(plt_risk, "figures/runge_risks.json")


# Plot to show convergence
function risks_by_sample_size(x_data, y_data, N0, k)
  h(x, θ) = polynomial(k, x, θ)
  Rs = Float64[]
  R̂s = Float64[]
  N1 = length(y_data)
  for n in N0:N1
    x = x_data[1:n]
    y = y_data[1:n]
    θ̂ = erm_polynomial_square_loss(x, y, k)
    push!(Rs, risk(runge, h, θ̂, domain, loss_sq))
    push!(R̂s, empirical_risk(x, y, h, θ̂, loss_sq))
  end

  return (Rs, R̂s)
end

N1 = 70
x_data = vcat(x_data, 2 * (rand(N1 - N) .- 0.5))
y_data = runge.(x_data)
k = 12

Rs, R̂s = risks_by_sample_size(x_data, y_data, N, k)

θ_min = min_risk_polynomial_square_loss(runge, k, domain)
risk_min = risk(runge, (x, θ) -> polynomial(k, x, θ), θ_min, domain, loss_sq)

D_vc = k + 1
η = 0.05
bounds = [vc_bound(n, D_vc, η, R̂s[i]) for (i, n) in enumerate(N:N1)]

conv_layout = base_layout(
  xaxis=axis_style(title="Number of observations", dtick=20, range=[N, N1]),
  yaxis=axis_style(title="Risk", axis_type="log",
    tickvals=[1, 1e-2, risk_min, 1e-4, 1e-6, 1e-8, 1e-10],
    ticktext=["10<sup>0</sup>", "10<sup>−2</sup>", "R<sup>*</sup>(H)", "10<sup>−4</sup>", "10<sup>−6</sup>", "10<sup>−8</sup>", "10<sup>−10</sup>"]),
  legend=legend_style(),
  hovermode="closest",
)

plt_conv = plot([
  scatter(
    x=collect(N:N1),
    y=Rs,
    name="Risk",
    mode="lines",
    line=attr(color=COLOR_PINK, width=2),
    hovertemplate="n = %{x}<br>R = %{y:.4f}<extra></extra>",
  ),
  scatter(
    x=collect(N:N1),
    y=R̂s,
    name="Empirical risk",
    mode="lines",
    line=attr(color=COLOR_CYAN, width=2, dash=:dash),
    hovertemplate="n = %{x}<br>R̂ = %{y:.4f}<extra></extra>",
  ),
  scatter(
    x=collect(N:N1),
    y=bounds,
    name="VC bound ($(Int(100 * (1 - η)))% confidence)",
    mode="lines",
    line=attr(color=COLOR_ORANGE, width=2, dash=:dashdot),
    hovertemplate="n = %{x}<br>Bound = %{y:.4f}<extra></extra>",
  ),
  scatter(
    x=[0, N1],
    y=[risk_min, risk_min],
    name="Minimum risk",
    mode="lines",
    line=attr(color=COLOR_BLACK, width=1, dash=:dot),
    hovertemplate="Minimum risk = %{y:.4f}<extra></extra>",
    showlegend=false,
  ),
], conv_layout)
display(plt_conv)
make_transparent!(plt_conv)
savefig(plt_conv, "figures/runge_convergence.json")
