using LinearAlgebra
using PlotlyJS

include("perceptrons.jl")
include("plot_utils.jl")

label(θ, x) = Int.(θ[2:end] ⋅ x > -θ[1])

function plot_data(X, y)
  symbols = [yᵢ == 1 ? "circle" : "circle-open" for yᵢ in y]
  trace = scatter(
    x=X[:, 1],
    y=X[:, 2],
    mode="markers",
    showlegend=false,
    marker=attr(
      color=COLOR_BLACK,
      line=attr(color=COLOR_BLACK, width=2),
      size=8,
      symbol=symbols),
    hoverinfo="text",
    hovertext=["y = $yᵢ" for yᵢ in y]
  )
  layout = base_layout(
    xaxis=axis_style(
      title="x₁",
      range=[-1.0, 1.0],
      zeroline=false,
      showgrid=false,
      showticklabels=false
    ),
    yaxis=axis_style(
      title="x₂",
      range=[-1.0, 1.0],
      zeroline=false,
      showgrid=false,
      showticklabels=false
    ),
    hovermode="closest",
    legend=legend_style(x=0.05, y=0.05, xanchor="left")
  )
  plot(trace, layout)
end

function add_line!(p, θ; label="", color=COLOR_BLACK, dash="solid")
  x1 = [-1.1, 1.1]
  x2 = @. -(θ[1] + θ[2] * x1) / θ[3]
  addtraces!(p,
    scatter(
      x=x1,
      y=x2,
      mode="lines",
      name=label,
      line=attr(color=color, width=2, dash=dash),
      hoverinfo="skip"
    )
  )
end

θ = [0, -2.0, 0.5]
X = [
  -0.895427 -0.133138
  -0.719505 0.859362
  -0.709035 0.238828
  -0.519476 0.293785
  -0.458034 -0.513898
  -0.391133 -0.175939
  -0.318047 -0.090539
  -0.070059 0.170865
  -0.147004 0.654426
  0.192512 -0.662951
  0.239501 -0.406004
  0.292543 -0.460517
  0.401021 -0.110378
  0.564798 -0.027114
  0.587323 -0.583174
  0.602885 -0.923553
  0.759180 -0.441460
  0.826881 0.504688
  0.898760 -0.608753
  0.942824 0.403362
]
y = label.(Ref(θ), eachrow(X))

T = 50000
θ₀ = zeros(3)
γs = [10 / (10 + t) for t = 1:T]
θ_svm, _ = svm(X, y, T, 0.001; θ_init=θ₀, γs=γs)
θ_alt = [0.7, -11.0, -0.5]

p = plot_data(X, y)
add_line!(p, θ_svm;
  label="Hypothesis A",
  color=COLOR_PINK)
add_line!(p, θ_alt;
  label="Hypothesis B",
  color=COLOR_CYAN,
  dash="dash")

display(p)

make_transparent!(p)
savefig(p, "figures/svm_induction.json")