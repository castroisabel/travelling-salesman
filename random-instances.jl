function processing_times_generator(m,n,cont)
    output_path = ("/home/isabecl/travelling-salesman/instances/")  # modify the path
    instance = string(output_path,"p", cont, ".txt")
    processing_times = open(instance, "w")

    for i in 1:m
        for j in 1:n
            r = rand(1:99)
            if i == j
                r = 10000
            end
            print(processing_times, r, "   ")
        end
        print(processing_times,"\n")
    end
    close(processing_times)
end

# Generating the instances
println("The generator begins...")

m =  n = 10
num_instances = 10

for j = 1:num_instances
    processing_times_generator(m,n,j)
end

println("The test instances were successful generated!")