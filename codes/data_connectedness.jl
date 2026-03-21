using Random


function is_connected(img)
  R, C = size(img)
  ones_pos = [(i, j) for i in 1:R for j in 1:C if img[i, j] == 1]

  if length(ones_pos) <= 1
    return true
  end

  visited = Set{Tuple{Int,Int}}([ones_pos[1]])
  queue = [ones_pos[1]]

  while !isempty(queue)
    (r, c) = popfirst!(queue)
    for (dr, dc) in [(-1,0), (1,0), (0,-1), (0,1)]
      nr, nc = r + dr, c + dc
      if 1 <= nr <= R && 1 <= nc <= C
        if img[nr, nc] == 1 && (nr, nc) ∉ visited
          push!(visited, (nr, nc))
          push!(queue, (nr, nc))
        end
      end
    end
  end

  return length(visited) == length(ones_pos)
end


function generate_connection_sample(R, C, P)
  if P < 0 || P > R * C
    error("P must satisfy 0 <= P <= R*C, got P=$P for $(R)×$(C) image")
  end

  vec_img = vcat(ones(Int, P), zeros(Int, R * C - P))
  shuffle!(vec_img)

  img = reshape(vec_img, R, C)
  connected = is_connected(img)

  return img, connected
end


function generate_connection_dataset(N, R, C, P; flatten=true)
  X = []
  y = []

  for _ in 1:N
    img, connected = generate_connection_sample(R, C, P)
    push!(X, img)
    push!(y, connected)
  end

  if flatten
    X = reduce(hcat, vec.(X))'
  end

  return X, y
end