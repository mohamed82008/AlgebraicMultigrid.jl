import AMG: Level, MultiLevel, GaussSeidel

function multigrid(A::SparseMatrixCSC{T,V}; max_levels = 10, max_coarse = 10,
                    presmoother = GaussSeidel(), postsmoother = GaussSeidel()) where {T,V}

    levels = Vector{Level{T,V}}()

    while length(levels) + 1 < max_levels && size(A, 1) > max_coarse
        A = extend!(levels, A)
        #=if size(A, 1) <= max_coarse
            # push!(levels, Level(A,spzeros(T,0,0),spzeros(T,0,0)))
            break
        end=#
    end

    MultiLevel(levels, A, presmoother, postsmoother)
end

function extend!(levels, A::SparseMatrixCSC{Ti,Tv}) where {Ti,Tv}

    size_F = size(A, 1)
    size_C = rem(size_F,2) == 0 ? div((size_F-1), 2) +1 : div((size_F-1), 2)
    total_len = size_C + 2 * (size_C - 1)

    I = Vector{Tv}(total_len)
    J = Vector{Tv}(total_len)
    V = Vector{Ti}(total_len)

    l = 1
    for k = 1:size_C
        I[l], J[l], V[l] = 2k, k, 1
        l += 1
    end
    for k = 1:size_C - 1
        I[l], J[l], V[l] = 2k+1, k, 0.5
        I[l+1], J[l+1], V[l+1] = 2k+1, k+1, 0.5
        l += 2
    end
    
    P = sparse(I, J, V, size_F, size_C)

    R = transpose(P)

    push!(levels, Level(A, P, R))

    R * A * P
end

Base.show(io::IO, level::Level) = print(io, "Level")

