struct SimpleEdge{T<:Integer} <: AbstractEdge
    v1::T
    v2::T

    SimpleEdge(v1::T, v2::T) where {T} = new{T}(minmax(v1, v2)...)
end

"""
    AdjacencyListNetwork <: AbstractNetwork

A network represented as an adjacency list.
It is the translation of `SimpleGraph` from Graphs.jl to the [`Network`](@ref) interface.

!!! warning

    This is mostly a example of compatibility with the Graphs.jl interface, but shouldn't be used as
    `Graphs.SimpleGraph` has proven to be problematic.
"""
mutable struct AdjacencyListNetwork{T<:Integer} <: AbstractNetwork
    fadjlist::Vector{Vector{T}}
    ne::Int
end

AdjacencyListNetwork{T}() where {T} = AdjacencyListNetwork{T}(Vector{Vector{T}}(), 0)
AdjacencyListNetwork{T}(n::Integer) where {T} = AdjacencyListNetwork{T}([T[] for _ in 1:n], 0)

Base.copy(g::AdjacencyListNetwork) = AdjacencyListNetwork(copy.(g.fadjlist), g.ne)

DelegatorTraits.ImplementorTrait(::Network, ::AdjacencyListNetwork) = DelegatorTraits.Implements()
EdgePersistence(::AdjacencyListNetwork) = RemoveEdges()
MatrixRepresentation(::AdjacencyListNetwork) = AdjacencyMatrix()

vertices(g::AdjacencyListNetwork) = 1:length(g.fadjlist)
edges(g::AdjacencyListNetwork) = SimpleEdgeIter(g)

all_vertices(g::AdjacencyListNetwork) = 1:length(g.fadjlist)
all_edges(g::AdjacencyListNetwork) = SimpleEdgeIter(g)

edge_incidents(::AdjacencyListNetwork, e::SimpleEdge) = [e.v1, e.v2]
vertex_incidents(g::AdjacencyListNetwork, v) = map(dst -> SimpleEdge(v, dst), g.fadjlist[v])

vertex_neighbors(g::AdjacencyListNetwork, v) = g.fadjlist[v]
function edge_neighbors(g::AdjacencyListNetwork, e::SimpleEdge)
    neigh_v1 = vertex_neighbors(g, e.v1)
    neigh_v2 = vertex_neighbors(g, e.v2)
    neighbors = Set{edge_type(g)}()

    for v in neigh_v1
        if v != e.v2
            push!(neighbors, SimpleEdge(e.v1, v))
        end
    end

    for v in neigh_v2
        if v != e.v1
            push!(neighbors, SimpleEdge(e.v2, v))
        end
    end

    return neighbors
end

vertex_type(::AdjacencyListNetwork{T}) where {T} = T
edge_type(::AdjacencyListNetwork{T}) where {T} = SimpleEdge{T}

hasvertex(g::AdjacencyListNetwork, v) = 1 <= v <= length(g.fadjlist)
hasedge(g::AdjacencyListNetwork, e::SimpleEdge) = e.v2 ∈ g.fadjlist[e.v1]

nvertices(g::AdjacencyListNetwork) = length(g.fadjlist)
nedges(g::AdjacencyListNetwork) = g.ne

edges_set_strand(::AdjacencyListNetwork{T}) where {T} = SimpleEdge{T}[]
edges_set_open(::AdjacencyListNetwork{T}) where {T} = SimpleEdge{T}[]
edges_set_hyper(::AdjacencyListNetwork{T}) where {T} = SimpleEdge{T}[]

function addvertex!(g::AdjacencyListNetwork)
    n = nvertices(g) + 1
    push!(g.fadjlist, Vector{vertex_type(g)}())
    return n
end

function addedge!(g::AdjacencyListNetwork, e::SimpleEdge)
    a, b = e.v1, e.v2
    @assert a ∈ vertices(g)
    @assert b ∈ vertices(g)

    if !hasedge(g, e)
        push!(g.fadjlist[a], b)
        push!(g.fadjlist[b], a)
        g.ne += 1
    end

    return e
end

function addedge!(g::AdjacencyListNetwork, u, v)
    e = SimpleEdge(u, v)
    return addedge!(g, e)
end

function rmvertex!(g::AdjacencyListNetwork, v)
    @assert hasvertex(g, v)

    # Update the adjacency lists of other vertices
    for (i, irow) in enumerate(g.fadjlist)
        filter!(!=(v), irow)
        irow .= -1
    end

    # Remove the vertex from the adjacency list
    deleteat!(g.fadjlist, v)

    return v
end

function rmedge!(g::AdjacencyListNetwork, e::SimpleEdge)
    @assert hasedge(g, e)
    a, b = e.v1, e.v2

    if hasedge(g, e)
        filter!(!=(b), g.fadjlist[a])
        filter!(!=(a), g.fadjlist[b])
        g.ne -= 1
    end

    return e
end

Base.@propagate_inbounds fadj(g::AdjacencyListNetwork) = g.fadjlist
Base.@propagate_inbounds fadj(g::AdjacencyListNetwork, u) = g.fadjlist[u]

struct SimpleEdgeIter{T}
    g::AdjacencyListNetwork{T}
end

Base.IteratorSize(::Type{<:SimpleEdgeIter}) = Base.HasLength()
Base.length(g::SimpleEdgeIter) = nedges(g.g)

Base.IteratorEltype(::Type{<:SimpleEdgeIter}) = Base.HasEltype()
Base.eltype(::Type{<:SimpleEdgeIter{T}}) where {T} = SimpleEdge{T}

@inline function Base.iterate(eit::SimpleEdgeIter{G}, state=(one(vertex_type(eit.g)), 1)) where {G}
    g = eit.g
    T = vertex_type(g)
    n = T(nvertices(g))
    u, i = state

    @inbounds while u < n
        list_u = fadj(g, u)
        if i > length(list_u)
            u += one(u)
            i = searchsortedfirst(fadj(g, u), u)
            continue
        end
        e = SimpleEdge(u, list_u[i])
        state = (u, i + 1)
        return e, state
    end

    @inbounds (n == 0 || i > length(fadj(g, n))) && return nothing

    e = SimpleEdge(n, n)
    state = (u, i + 1)
    return e, state
end
