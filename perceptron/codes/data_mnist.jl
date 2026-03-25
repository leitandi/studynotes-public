  using MLDatasets: MNIST

  const S = 28 # MNIST image size is S x S

  function load_mnist(batch=:train, subset49=false)
    dataset = MNIST(batch)
    X, y = dataset[:]
    
    # Flatten matrix into a vector, so that X is N x K, K = S * S
    X = reshape(X, S * S, :)'

    if subset49
      (X, y) = pick49(X, y)
    end

    return (X, y)
  end

  function pick49(X, y)
    idx = (y .== 4) .|| (y .== 9)

    # Subset data
    y = y[idx]
    X = X[idx, :]  

    # Indicator for label == 4
    y = (y .== 4)

    return (X, y)
  end

mnist_vec_to_matrix(x) = reshape(x, (S, S))