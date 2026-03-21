using LinearAlgebra
using Random

rbf_kernel(x, y, γ) = exp(-γ * norm(x - y)^2)
polynomial_kernel(x, y, c, d) = (x ⋅ y + c)^d

function pegasos(X, ỹ, λ, T::Int, b=0.0; seed=nothing)
  N, K = size(X)
  w = zeros(K)
  indices = permute_indices(N, seed)

  @inbounds for t = 1:T
    # Select observation
    i = indices[mod1(t, N)]
    ỹᵢ = ỹ[i]
    xᵢ = @view X[i, :]

    # Compute score and step size
    scoreₜ = ỹᵢ * (dot(w, xᵢ) + b)
    ηₜ = 1 / (λ * t)

    # Update in-place
    scale = 1 - ηₜ * λ
    if scoreₜ < 1
      coef = ηₜ * ỹᵢ
      @simd for j in eachindex(w)
        w[j] = scale * w[j] + coef * xᵢ[j]
      end
    else
      @simd for j in eachindex(w)
        w[j] *= scale
      end
    end
  end
  return w
end

function pegasos_kernel(X, ỹ, λ, T, G::Matrix; seed=nothing)
  N = size(X, 1)
  α = zeros(N)
  indices = permute_indices(N, seed)

  @inbounds for t = 1:T
    i = indices[mod1(t, N)]
    ỹᵢ = ỹ[i]

    scoreₜ = ỹᵢ / (λ * t) * dot(α .* ỹ, @view G[i, :])

    if scoreₜ < 1
      α[i] += 1
    end
  end

  return α
end

function permute_indices(N, seed=nothing)
  rng = isnothing(seed) ? default_rng() : MersenneTwister(seed)
  return randperm(rng, N)
end

function cross_gram_matrix(X_train, X_test, kernel)
  N_train = size(X_train, 1)
  N_test = size(X_test, 1)
  K = zeros(N_test, N_train)
  for j in 1:N_test
    xⱼ = @view X_test[j, :]
    for i in 1:N_train
      K[j, i] = kernel(@view(X_train[i, :]), xⱼ)
    end
  end
  return K
end

function gram_matrix(X, kernel)
  N = size(X, 1)
  G = zeros(N, N)
  for i in 1:N
    xᵢ = @view X[i, :]
    for j in i:N
      xⱼ = @view X[j, :]
      G[i, j] = kernel(xᵢ, xⱼ)
      G[j, i] = G[i, j]
    end
  end
  @assert minimum(eigvals(G)) ≥ -sqrt(eps()) "Gram matrix is not positive semidefinite"
  return G
end
