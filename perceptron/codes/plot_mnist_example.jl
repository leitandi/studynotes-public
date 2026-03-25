include("data_mnist.jl")
include("plot_utils.jl")

X, y = load_mnist(:train, true)

image = mnist_vec_to_matrix(X[3, :])
height = size(image, 1)
width = size(image, 2)
K = height * width
k_index = reshape(1:K, size(image))

trace = heatmap(
  z = image',
  x = 1:width,
  xgap = 1,
  y = 1:height,
  ygap = 1,
  customdata = k_index,
  colorscale = [(0, COLOR_BLACK), (1, "rgba(0,0,0,0)")],
  reversescale = true,
  showscale = false,
  hovertemplate = "<i>k</i> = %{customdata} <br><i>x<sub>i, k</sub></i> = %{z:.3f}",
  name = "",
  hoverlabel = attr(bgcolor = COLOR_BLACK),
)

p = plot(trace)
relayout!(p,
  xaxis_visible = false,
  yaxis_visible = false,
  yaxis_autorange = "reversed",
  yaxis_scaleanchor = "x",
  shapes = [attr(
    type = "rect",
    xref = "x",
    yref = "y",
    x0 = 0.5,
    y0 = 0.5,
    x1 = width + 0.5,
    y1 = height + 0.5,
    line = attr(color = COLOR_BLACK, width = 2)
  )]
)
display(p)

make_transparent!(p)
savefig(p, "figures/mnist_digit.json")