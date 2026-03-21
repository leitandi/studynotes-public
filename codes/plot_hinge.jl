using LinearAlgebra
include("plot_utils.jl")

slack(x, δ) = max(0, δ - x)

δ = 1.0
xs = -4.0:0.01:4.0
slack_vals = slack.(xs, Ref(δ))
y_min = -0.8
y_max = maximum(slack_vals)

layout = base_layout(
  xaxis=axis_style(
    title="Signed score",
    tickvals=[0, δ],
    ticktext=["0", "δ"],
    range=[-3.5, 3.5]
  ),
  yaxis=axis_style(
    title="Robust slack",
    tickvals=[0],
    ticktext=["0"],
    range=[y_min, y_max]
  ),
  showlegend=false,
  hovermode=false,
  shapes=[attr(
    type="line",
    xref="x",
    yref="y",
    x0=δ,
    x1=δ,
    y0=y_min,
    y1=0,
    line=attr(color=COLOR_BLACK, width=1, dash="dot")
  )]
)

plt = plot([
  scatter(
    x = xs,
    y = slack_vals,
    name = "Slack",
    hoverinfo="skip",
    line=attr(color=COLOR_PINK, width=2.5)
  ),
], layout)

display(plt)
make_transparent!(plt)
savefig(plt, "figures/hinge.json")





