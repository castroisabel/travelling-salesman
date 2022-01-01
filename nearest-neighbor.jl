using DelimitedFiles
include("2-opt.jl")

num_instances = 10
N = 10
output_path = ("/home/isabecl/travelling-salesman/")


function nearest_neighbor(N, p)
    is_selected = Bool[]
    for i = 1:N
        push!(is_selected, false) 
    end
    is_selected[1] = true

    way = Int[]
    for i = 1:N
        push!(way, 1)
    end

    for i=1:N-1
        k = way[i]
        selected_neighbor = 1
        best_cost = sum(p)

        for j=1:N
            if !is_selected[j] & (p[k,j] != 10000) & (best_cost > p[k,j])
                selected_neighbor = j
                best_cost = p[k,j]
            end  
        end 
        way[i+1] =  selected_neighbor
        is_selected[selected_neighbor] = true     
    end
    
    return way
end

function calculate_cost(N, p, way)
    cost = 0

    for i=1:N
        city_A = way[i]
        if i == N
            city_B = 1
        else
            city_B = way[i+1]
        end
        cost = cost + p[city_A,city_B]

    end
    
    return cost
end 

function read_processing_times(cont)
    input_path = ("/home/isabecl/travelling-salesman/instances/")  #remember to modify the path
    processing_time_instance = string(input_path,"p", cont, ".txt")
    p = readdlm(processing_time_instance, Int)
    return(p)
end

p = Array{Int64,2}[]
for j = 1:num_instances
    push!(p, read_processing_times(j))
end

file_name = string(output_path,"nearest_neighbor_results.txt")
results_nn = open(file_name, "w")
println(results_nn,"Instance - Route - Cost ")
close(results_nn)

for j=1:num_instances
    c = nearest_neighbor(N, p[j])
    println(j,"   ", c)
    cost = calculate_cost(N, p[j], c)

    results_nn = open(file_name, "a")
    println(results_nn, j,"   ", c, "   ", cost)

    c, cost = improve(p[j],c)

    println(results_nn, j,"   ", c,"   ",cost, " (2-opt)")
    close(results_nn)
end
