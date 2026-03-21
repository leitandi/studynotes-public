using Optim
using ADTypes
import ForwardDiff
using QuadGK
using Statistics

loss_abs(y, ŷ) = abs(y - ŷ)
loss_sq(y, ŷ) = (y - ŷ)^2

risk(f, h, θ, domain, L) = quadgk(x -> L(f(x), h(x, θ)), domain[1], domain[2])[1] / (domain[2] - domain[1])

empirical_risk(x, y, h, θ, L) = mean(L.(y, h.(x, Ref(θ))))

function erm(x, y, h, θ₀, loss=:square; options=Optim.Options())
  L = loss === :absolute ? loss_abs :
    loss === :square ? loss_sq :
    throw(ArgumentError("loss must be :absolute or :square"))

  obj = θ -> empirical_risk(x, y, h, θ, L)

  if loss === :square
    result = optimize(obj, θ₀, Optim.LBFGS(), options; autodiff=AutoForwardDiff())
  else
    result = optimize(obj, θ₀, Optim.NelderMead(), options)
  end

  return Optim.minimizer(result), result
end

function erm_polynomial_square_loss(x, y, k)
  A = [sum(x.^(s + t)) for s=0:k, t=0:k]
  b = [sum(y .* x.^s) for s=0:k]
  return A \ b
end

function min_risk_polynomial_square_loss(f, k, domain)
  x0, x1 = domain
  A = [(x1^(s+t+1) - x0^(s+t+1)) / (s + t + 1) for s=0:k, t=0:k]
  b = [quadgk(x -> f(x) * x^s, x0, x1)[1] for s=0:k]
  return A \ b
end
