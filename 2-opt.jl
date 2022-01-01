function two_opt(way,i,j)
    new_way  = copy(way)
    new_way[i+1:j+1] = reverse(new_way[i+1:j+1])

    return new_way
end


function improve(p, way)
    cost = calculate_cost(p, way)
    candidate = copy(way)
    br = 1 
    while(br == 1)
        for node1=2:length(way)-2
            for node2=node1+1:length(way)-1
                if (node1 != 1) | (node2 != length(way)-2)
                    new_way = two_opt(way, node1, node2)
                    new_cost = calculate_cost(p, new_way)
                    if new_cost < cost
                        cost = new_cost
                        candidate = copy(new_way)
                        br = 0
                    end
                end
            end
        end

        way = copy(candidate)
        if br == 1
            break
        else
            br = 1
        end
    end

    return way, cost
end

function calculate_cost(p, way)
    cost = 0
    N = length(way)
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
