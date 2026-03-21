include("classical_perceptron.jl")
include("data_connectedness.jl")
include("plot_utils.jl")

Random.seed!(42)

R = 8
C = 8
P = 48

N_train = 10000
N_test = 2000

X, y = generate_connection_dataset(N_train, R, C, P)

println("N_train = $N_train")
println("mean y = $(mean(y))")

X̃ = prepend_ones(X)
T = 1000
η = 0.1
θ_init = ones(size(X̃, 2))
α = 0.01

θ̂_rb = classical_perceptron_adam(X̃, y, T, θ_init, α)

println("final risk = $(risk(X̃, y, θ̂_rb))")
println("train error: $(error_rate(X̃, y, θ̂_rb))")

X_test, y_test = generate_connection_dataset(N_test, R, C, P)
X̃_test = prepend_ones(X_test)
println("test error: $(error_rate(X̃_test, y_test, θ̂_rb))")
