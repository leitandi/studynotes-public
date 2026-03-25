include("plot_utils.jl")

i = 3
n = 10
xs = vcat(1:i-1, i+1:n)
ys = vcat(1:i-1, i+1:n)

trace_data = scatter(
  x=xs,
  y=ys,
  mode="markers",
  name="Observations",
  marker=attr(color=COLOR_BLACK, size=10, symbol="circle"),
  hoverinfo="skip"
)

A_marker = scatter(
  x=[i],
  y=[i],
  mode="markers",
  name="Hypothesis A ",
  marker=attr(color=COLOR_PINK, size=10, symbol="square"),
  hoverinfo="skip"
)

B_marker = scatter(
  x=[i],
  y=[7],
  mode="markers",
  name="Hypothesis B ",
  marker=attr(color=COLOR_CYAN, size=10, symbol="diamond"),
  hoverinfo="skip"
)

layout = base_layout(
  xaxis=axis_style(title="x", dtick=1, zeroline=false),
  yaxis=axis_style(title="y", dtick=1, zeroline=false),
  showlegend=true,
  legend=legend_style(),
  hovermode=false
)

p = plot([trace_data, A_marker, B_marker], layout)
display(p)
make_transparent!(p)
savefig(p, "figures/complexity.json")
