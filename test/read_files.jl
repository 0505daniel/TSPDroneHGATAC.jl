using DelimitedFiles
using TSPLIB

function Calculate_distance_matrices_Agatz(alpha::Float64, depot::Tuple{Float64,Float64}, Nodes::Vector{Tuple{Float64,Float64}})
    num_of_nodes = length(Nodes)
    D = zeros(num_of_nodes, num_of_nodes)
    T = zeros(num_of_nodes, num_of_nodes)
    Dp = zeros(num_of_nodes)
    Tp = zeros(num_of_nodes)
    for i = 1:num_of_nodes
        Dp[i] = euclidean(depot, Nodes[i]) / alpha
        Tp[i] = euclidean(depot, Nodes[i])
        for j = 1:num_of_nodes
            D[i, j] = euclidean(Nodes[i], Nodes[j]) / alpha
            T[i, j] = euclidean(Nodes[i], Nodes[j])
        end
    end


    DD = zeros(num_of_nodes + 2, num_of_nodes + 2)
    TT = zeros(num_of_nodes + 2, num_of_nodes + 2)
    DD[2:num_of_nodes+1, 2:num_of_nodes+1] = D
    DD[2:num_of_nodes+1, 1] = Dp
    DD[1, 2:num_of_nodes+1] = Dp
    DD[2:num_of_nodes+1, num_of_nodes+2] = Dp
    DD[num_of_nodes+2, 2:num_of_nodes+1] = Dp
    TT[2:num_of_nodes+1, 2:num_of_nodes+1] = T
    TT[2:num_of_nodes+1, 1] = Tp
    TT[1, 2:num_of_nodes+1] = Tp
    TT[2:num_of_nodes+1, num_of_nodes+2] = Tp
    TT[num_of_nodes+2, 2:num_of_nodes+1] = Tp

    return TT, DD
end

function read_data_Agatz(sample::String)
    distribution = split(sample, "-")[1]
    filename = joinpath(@__DIR__, "Test_instances/TSPD-Instances-Agatz/$(distribution)/$(sample).txt")
    f = open(filename, "r")
    lines = readlines(f)

    alpha = parse(Float64, lines[2]) / parse(Float64, lines[4])
    n_nodes = parse(Int64, lines[6]) - 1
    depot = (parse(Float64, split(lines[8], " ")[1]), parse(Float64, split(lines[8], " ")[2]))
    customers = Vector{Tuple{Float64,Float64}}()
    for i = 1:n_nodes
        node = (parse(Float64, split(lines[9+i], " ")[1]), parse(Float64, split(lines[9+i], " ")[2]))
        push!(customers, node)
    end
    T, D = Calculate_distance_matrices_Agatz(alpha, depot, customers)
    return T, D
end

function read_data_Agatz_restricted(sample::String)
    filename = joinpath(@__DIR__, "Test_instances/TSPD-Instances-Agatz/restricted/maxradius/$(sample).txt")
    f = open(filename, "r")
    lines = readlines(f)
    flying_range = parse(Float64, split(lines[1], " ")[2])
    alpha = parse(Float64, lines[4]) / parse(Float64, lines[6])
    n_nodes = parse(Int64, lines[8]) - 1
    depot = (parse(Float64, split(lines[10], " ")[1]), parse(Float64, split(lines[10], " ")[2]))
    customers = Vector{Tuple{Float64,Float64}}()
    for i = 1:n_nodes
        node = (parse(Float64, split(lines[11+i], " ")[1]), parse(Float64, split(lines[11+i], " ")[2]))
        push!(customers, node)
    end
    T, D = Calculate_distance_matrices_Agatz(alpha, depot, customers)
    return T, D, flying_range
end

function read_data_Bogyrbayeva(file_name::String, sample_number::Int)
    distribution, _, n_nodes_ = split(file_name, "-")
    n_nodes = parse(Int, n_nodes_)
    filename = joinpath(@__DIR__, "Test_instances/TSPD-Instances-Bogyrbayeva/$(distribution)/$(file_name).txt")
    f = open(filename, "r")
    lines = readlines(f)
    data = parse.(Float64, split(lines[sample_number], " "))
    depot = [data[1], data[2]]
    customers = zeros(n_nodes - 1, 2)
    for i = 2:n_nodes
        customers[i-1, 1] = data[2*i-1]
        customers[i-1, 2] = data[2*i]
    end
    return depot, customers
end


function read_Murray(file_name::String)
    n_nodes = 10
    filename = joinpath(@__DIR__, "Test_Instances/FSTSP-Instances-Murray/FSTSP_10_customer_problems/$(file_name)/tau.csv")
    T = readdlm(filename, header=false, ',')
    filename = joinpath(@__DIR__, "Test_Instances/FSTSP-Instances-Murray/FSTSP_10_customer_problems/$(file_name)/tauprime.csv")
    D = readdlm(filename, header=false, ',')
    TT = zeros(n_nodes + 2, n_nodes + 2)
    DD = zeros(n_nodes + 2, n_nodes + 2)
    for i = 1:n_nodes+2
        for j = 1:n_nodes+2
            if i == n_nodes + 2
                TT[i, j] = T[1, j]
                DD[i, j] = D[1, j]
            else
                TT[i, j] = T[i, j]
                DD[i, j] = D[i, j]
            end
        end
    end
    filename = joinpath(@__DIR__, "Test_Instances/FSTSP-Instances-Murray/FSTSP_10_customer_problems/$(file_name)/nodes.csv")
    d = readdlm(filename, header=false, ',')
    dEligible = Int[]
    for i = 0:10
        if d[i+1, 4] == 1
            push!(dEligible, i)
        end
    end
    return TT, DD, dEligible
end

function read_data_Ha(file_name::String)
    filename = joinpath(@__DIR__, "Test_instances/FSTSP-Instances-Ha/$(file_name).txt")
    f = open(filename, "r")
    lines = readlines(f)
    n_nodes = parse(Int, split(lines[1], " ")[2])
    tspeed = parse(Float64, split(lines[5], " ")[2]) / 60
    dspeed = parse(Float64, split(lines[4], " ")[2]) / 60
    flying_range = 20.0
    sL = 1.0
    sR = 1.0
    # flying_range = parse(Float64, split(lines[7]," ")[2]) * 60
    # sL = parse(Float64, split(lines[9]," ")[2]) * 60
    # sR = parse(Float64, split(lines[10]," ")[2]) * 60 
    depot = parse.(Float64, split(lines[19], " ")[[2, 3]])
    customers = zeros(n_nodes, 2)
    dEligible = Int[]
    for i = 1:n_nodes
        customers[i, :] = parse.(Float64, split(lines[19+i], " ")[[2, 3]])
        if parse(Int, split(lines[19+i], " ")[4]) == 1
            push!(dEligible, i)
        end
    end
    return depot, customers, dEligible, tspeed, dspeed, flying_range, sL, sR
end

function Read_TSPLIB_instance(sample_name::Symbol)
    tsp = readTSPLIB(sample_name)
    allNodes = tsp.nodes
    num_of_nodes = size(allNodes)[1] - 1
    dEligible = Int[]
    for i in 1:num_of_nodes
        r = 0.85 + 0.05 * rand()
        if rand() > r
            push!(dEligible, i)
        end
    end
    depot = allNodes[1, :]
    Customers = allNodes[2:num_of_nodes+1, :]

    return depot, Customers, dEligible
end