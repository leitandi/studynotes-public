using LinearAlgebra
using StatsBase
include("pegasos.jl")

prepend_ones(X) = hcat(ones(eltype(X), size(X, 1)), X)

heaviside(x) = x > 0
hypothesis(X̃, θ) = heaviside.(X̃ * θ)

error(X̃, y, θ) = y .- hypothesis(X̃, θ)
error_robust(X̃, ỹ, θ, δ = 1.0) = ỹ .* (δ .> ỹ .* (X̃ * θ))

error_rate(e) = mean(abs.(e))
error_rate(X̃, y, θ) = error_rate(error(X̃, y, θ))

hypothesis_kernel(K, ỹ_train, α) = heaviside.(K * (α .* ỹ_train))

error_rate_kernel(K, ỹ_train, y_test, α) =
  mean(y_test .!= hypothesis_kernel(K, ỹ_train, α))

hinge_criterion(X̃, ỹ, θ, N, δ = 1.0) = (δ * ỹ .- (X̃ * θ)) ⋅ error_robust(X̃, ỹ, θ, δ) / N

function hinge(X̃, ỹ, θ, N, δ = 1.0)
	score = X̃ * θ
	ẽ = ỹ .* (δ .> ỹ .* score) / N
	f = (δ * ỹ .- score) ⋅ ẽ
	∇f = -(X̃' * ẽ)
	return (f, ∇f)
end

function hinge_regularized(X̃, ỹ, θ, λ, N, δ = 1.0)
	(f, ∇f) = hinge(X̃, ỹ, θ, N, δ)
	return (f + λ * 0.5 * sum(w(θ) .^ 2), ∇f + λ * vcat(0, w(θ)))
end

w(θ) = θ[2:end]

function subgradient_method(fg, K::Int, x₀, αs)
	x = copy(x₀)
	x_best = copy(x₀)
	(f_best, _) = fg(x₀)
	criteria = Vector{eltype(x₀)}(undef, K + 1)
	criteria[1] = f_best
	for k ∈ 1:K
		(f_k, g_k) = fg(x)
		criteria[k+1] = f_k
		if f_k < f_best
			f_best = f_k
			x_best .= x  # save BEFORE the step
		end
		x .-= αs[k] .* g_k
	end
	return (x_best, criteria)
end

function subgradient_polyak(fg, K::Int, x₀, γs)
	x = copy(x₀)
	x_best = copy(x₀)
	(f_best, _) = fg(x₀)
	criteria = Vector{eltype(x₀)}(undef, K + 1)
	criteria[1] = f_best
	for k ∈ 1:K
		(f_k, g_k) = fg(x)
		criteria[k+1] = f_k
		if f_k < f_best
			f_best = f_k
			x_best .= x
		end
		α_k = (f_k - f_best + γs[k]) / (g_k ⋅ g_k)
		x .-= α_k .* g_k
	end
	return (x_best, criteria)
end

function classical_perceptron(X, y, T, δ; θ_init = nothing, αs = 0.01)
	X̃ = prepend_ones(X)
	ỹ = 2y .- 1
	N = length(y)

	θ_init = isnothing(θ_init) ? ones(eltype(X̃), size(X̃, 2)) : θ_init
	αs = (αs isa Number) ? fill(αs, T) : αs

	fg(θ) = hinge(X̃, ỹ, θ, N, δ)
	return subgradient_method(fg, T, θ_init, αs)
end

function svm(X, y, T, λ; θ_init = nothing, γs = 1.0)
	X̃ = prepend_ones(X)
	ỹ = 2y .- 1
	N = length(y)

	θ_init = isnothing(θ_init) ? ones(eltype(X̃), size(X̃, 2)) : θ_init
	γs = (γs isa Number) ? fill(γs, T) : γs

	fg(θ) = hinge_regularized(X̃, ỹ, θ, λ, N)
	return subgradient_polyak(fg, T, θ_init, γs)
end
