using JuMP, Gurobi, PyPlot, DelimitedFiles

num_instances = 10
output_path = ("/home/isabecl/travelling-salesman/")


function read_processing_times(cont)
    input_path = ("/home/isabecl/travelling-salesman/instances/")
    processing_time_instance = string(input_path,"p", cont, ".txt")
    p = readdlm(processing_time_instance, Int)
    return(p)
end


function MILP(p)
    N = size(p,1)

    # Model building
    model = Model(optimizer_with_attributes(Gurobi.Optimizer))

    # Decision variables
    @variable(model, x[1:N,1:N], Bin)

    # Objective function
    @objective(model, Min, sum(x[i,j]*p[i,j] for i=1:N,j=1:N))

    # Constraints
    for i=1:N 
        @constraint(model, x[i,i] == 0)
        @constraint(model, sum(x[i,1:N]) == 1)
    end
    for j=1:N
        @constraint(model, sum(x[1:N,j]) == 1)
    end
    for f=1:N, t=1:N
        @constraint(model, x[f,t]+x[t,f] <= 1)
    end
    
    status = optimize!(model)


    function is_tsp_solved(m,x)
        N = size(x)[1]
        x_val = JuMP.value.(x)
        
        # find cycle
        cycle_idx = Int[]
        push!(cycle_idx, 1)
        while true
            v, idx = findmax(x_val[cycle_idx[end],1:N])
            if idx == cycle_idx[1]
                break
            else
                push!(cycle_idx,idx)
            end
        end
        println("cycle_idx: ", cycle_idx)
        println("Length: ", length(cycle_idx))
        if length(cycle_idx) < N
            @constraint(m, sum(x[cycle_idx,cycle_idx]) <= length(cycle_idx)-1)
            return false
        end
        println("cycle_idx: ", cycle_idx)
        println("Length: ", length(cycle_idx))
        return true, cycle_idx
    end 
    
    
    # Solving the model
    while !is_tsp_solved(model, x)[1]
        status = optimize!(model)
    end

    cycle =  is_tsp_solved(model, x)[2]
    zIP = objective_value(model)
    tzIP = MOI.get(model, MOI.SolveTime())

    return(zIP, tzIP, cycle)
end

# Saving distances in an array
p = Array{Int64,2}[]
for j = 1:num_instances
    push!(p, read_processing_times(j))
end

file_name = string(output_path,"results.txt")
results = open(file_name, "w")
println(results,"Instance - Route - Cost ")
close(results)

for j = 1:num_instances
    println()
    println("MILP model is starting!")

    # Running MILP
    zIP, tzIP, way = MILP(p[j])
    results = open(file_name, "a")
    println(results,j,"   ",way,"   ",zIP)
    close(results)
    println(j, ") ","MILP-1 ",zIP,"   ",tzIP)
end

println("The MILP model was suscefull run!")