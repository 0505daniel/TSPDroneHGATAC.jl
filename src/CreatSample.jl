using Distances

function Calculate_duration_matrices(tspeed::Int, dspeed::Int, depot::Tuple{Float64}, Customers::Matrix{Float64})
    num_of_nodes = size(Customers)[1] 
    D = Matrix{Float64}(undef, num_of_nodes + 2, num_of_nodes + 2)
    T = Matrix{Float64}(undef, num_of_nodes + 2, num_of_nodes + 2)
    D[1, 1] = 0.0
    D[num_of_nodes+2, num_of_nodes+2] = 0.0
    D[1, num_of_nodes+2] = 0.0
    D[num_of_nodes+2, 1] = 0.0
    T[1, 1] = 0.0
    T[num_of_nodes+2, num_of_nodes+2] = 0.0
    T[1, num_of_nodes+2] = 0.0
    T[num_of_nodes+2, 1] = 0.0
    @inbounds for i in 1:num_of_nodes
        D[i+1, i+1] = 0.0
        T[i+1, i+1] = 0.0
        D[1, i+1] = euclidean(depot, Customers[i, :]) / dspeed
        D[i+1, 1] = D[1, i+1]
        D[num_of_nodes+2, i+1] = D[1, i+1]
        D[i+1, num_of_nodes+2] = D[1, i+1]
        T[1, i+1] = cityblock(depot, Customers[i, :]) / tspeed
        T[i+1, 1] = T[1, i+1]
        T[num_of_nodes+2, i+1] = T[1, i+1]
        T[i+1, num_of_nodes+2] = T[1, i+1]
        @inbounds for j in 1:num_of_nodes
            D[i+1, j+1] = euclidean(Customers[i, :], Customers[j, :]) / dspeed
            D[j+1, i+1] = D[i+1, j+1]
            T[i+1, j+1] = cityblock(Customers[i, :], Customers[j, :]) / tspeed
            T[j+1, i+1] = T[i+1, j+1]
        end
    end

    return T, D
end