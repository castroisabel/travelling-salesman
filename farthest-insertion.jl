using DelimitedFiles
include("2-opt.jl")

num_instances = 10
N = 10
output_path = ("/home/isabecl/travelling-salesman/")


function farthest_insertion(way, N, p)
    selected_neighbor = Nothing()
    ref = Nothing()
    best_cost = 0
    total_cost = 0

    for i in way
        for j=1:N
            if !(j in way) & (p[i,j] != 10000) & (best_cost <= p[i,j])
                selected_neighbor = j
                best_cost = p[i,j]
                ref = i
            end  
        end  

    end

    if ref == Nothing()
        return nothing
    else 
        return selected_neighbor, ref, best_cost
    end
end


function include_new_neighbor(way, p, candidate)
    new_way = []
    if length(way) == 1
        new_way = [1,candidate,1]
    else
        best_cost = sum(p)
        insertion_position = Nothing()
        
        for i=2:length(way)
            current_node =  way[i]
            previous_node = way[i-1]
            current_cost = p[previous_node, current_node]
            new_cost = p[previous_node, candidate]+p[candidate, current_node]
            updated_cost = new_cost-current_cost
            if updated_cost < best_cost
                best_cost = updated_cost
                insertion_position= i
            end
        end

        new_way = vcat(way[1:insertion_position-1],candidate,way[insertion_position:length(way)])
    end
    
    return new_way
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
    input_path = ("/home/isabecl/travelling-salesman/instances/") #remember to modify the path
    processing_time_instance = string(input_path,"p", cont, ".txt")
    p = readdlm(processing_time_instance, Int)
    return(p)
end

p = Array{Int64,2}[]
for j = 1:num_instances
    push!(p, read_processing_times(j))
end


file_name = string(output_path,"farthest_insertion_results.txt")
results_fi = open(file_name, "w")
println(results_fi,"Instance - Route - Cost ")
close(results_fi)

for j=1:num_instances
    way = [1]
    while length(way)<=N
        candidate, ref, cost = farthest_insertion(way, N, p[j])
        way = include_new_neighbor(way, p[j], candidate)
    end

    way = way[1:length(way)-1]
    cost = calculate_cost(N, p[j], way)

    println(j,"   ", way)

    results_fi = open(file_name, "a")
    println(results_fi, j,"   ", way,"   ",cost)
    
    way, cost = improve(p[j],way)

    println(results_fi, j,"   ", way,"   ",cost, " (2-opt)")
    close(results_fi)
end
