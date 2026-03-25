using PlotlyJS
using JSON3

const COLOR_PINK = "#cc1376"
const COLOR_CYAN = "#00c8ff"
const COLOR_ORANGE = "#ff6600"
const COLOR_BLACK = "#060611"
const COLOR_GREEN = "#96ff32"
const COLOR_PURPLE = "#9b59b6"


function axis_style(;
  title="",
  range=nothing,
  fixedrange=true,
  showgrid=false,
  zeroline=true,
  zerolinecolor=COLOR_BLACK,
  zerolinewidth=1,
  showline=true,
  linecolor=COLOR_BLACK,
  linewidth=2,
  mirror=true,
  tickvals=nothing,
  ticktext=nothing,
  dtick=nothing,
  showticklabels=true,
  autorange=nothing,
  rangemode=nothing,
  axis_type=nothing,
  tickformat=nothing,
  exponentformat=nothing)

  pairs = Any[
    :title => title,
    :fixedrange => fixedrange,
    :showgrid => showgrid,
    :zeroline => zeroline,
    :zerolinecolor => zerolinecolor,
    :zerolinewidth => zerolinewidth,
    :showline => showline,
    :linecolor => linecolor,
    :linewidth => linewidth,
    :mirror => mirror,
    :showticklabels => showticklabels,
  ]

  if !isnothing(range)
    push!(pairs, :range => range)
    if isnothing(autorange)
      autorange = false
    end
  end
  if !isnothing(autorange)
    push!(pairs, :autorange => autorange)
  end
  if !isnothing(rangemode)
    push!(pairs, :rangemode => rangemode)
  end
  if !isnothing(tickvals)
    push!(pairs, :tickvals => tickvals)
  end
  if !isnothing(ticktext)
    push!(pairs, :ticktext => ticktext)
  end
  if !isnothing(dtick)
    push!(pairs, :dtick => dtick)
  end
  if !isnothing(axis_type)
    push!(pairs, :type => axis_type)
  end
  if !isnothing(tickformat)
    push!(pairs, :tickformat => tickformat)
  end
  if !isnothing(exponentformat)
    push!(pairs, :exponentformat => exponentformat)
  end

  return attr(; pairs...)
end

function legend_style(;
  x=0.95,
  y=0.05,
  xanchor="right",
  yanchor="bottom",
  bgcolor="rgba(255,255,255,0.8)",
  bordercolor=COLOR_BLACK,
  borderwidth=1)

  return attr(
    x=x,
    y=y,
    xanchor=xanchor,
    yanchor=yanchor,
    bgcolor=bgcolor,
    bordercolor=bordercolor,
    borderwidth=borderwidth
  )
end

function base_layout(;
  xaxis=nothing,
  yaxis=nothing,
  legend=nothing,
  hovermode=nothing,
  showlegend=nothing,
  kwargs...)

  pairs = Any[]
  if !isnothing(xaxis)
    push!(pairs, :xaxis => xaxis)
  end
  if !isnothing(yaxis)
    push!(pairs, :yaxis => yaxis)
  end
  if !isnothing(legend)
    push!(pairs, :legend => legend)
  end
  if !isnothing(hovermode)
    push!(pairs, :hovermode => hovermode)
  end
  if !isnothing(showlegend)
    push!(pairs, :showlegend => showlegend)
  end
  for (k, v) in kwargs
    push!(pairs, k => v)
  end
  return Layout(; pairs...)
end

function make_transparent!(p)
  relayout!(p,
    plot_bgcolor = "rgba(0,0,0,0)",
    paper_bgcolor = "rgba(0,0,0,0)")
  return p
end