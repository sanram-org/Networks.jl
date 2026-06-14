struct Network <: Interface end

# auxiliar types
abstract type AbstractNetwork end

abstract type AbstractVertex end
struct Vertex{T} <: AbstractVertex
    id::T
end

abstract type AbstractEdge end
struct Edge{T} <: AbstractEdge
    id::T
end

# traits
"""
    MatrixRepresentation

Trait for the matrix type used for representating the finite [`Network`](@ref).
"""
abstract type MatrixRepresentation end
struct AdjacencyMatrix <: MatrixRepresentation end
struct IncidenceMatrix <: MatrixRepresentation end

@delegated interface=Network() MatrixRepresentation(graph)

"""
    EdgePersistence

Trait for edge persitence in a [`Network`](@ref). It defines the behavior of edges when a vertex is removed.
The following traits are defined:

  - `PersistEdges`: edges are **never** removed implicitly.
  - `RemoveEdges`: edges are **always** removed implicitly.
  - `PruneEdges` (default): edges are removed if left stranded (i.e. no other vertex is linked with it).
"""
abstract type EdgePersistence end
struct PersistEdges <: EdgePersistence end
struct RemoveEdges <: EdgePersistence end
struct PruneEdges <: EdgePersistence end

@delegated interface=Network() EdgePersistence(graph) = PruneEdges()

# query methods
function vertices end
vertices(graph; kwargs...) = vertices(sort_nt(kwargs), graph)
vertices(::NamedTuple{}, graph) = all_vertices(graph)

function edges end
edges(graph; kwargs...) = edges(sort_nt(kwargs), graph)
edges(::NamedTuple{}, graph) = all_edges(graph)
function edges(::@NamedTuple{set::Symbol}, graph)
    if set == :open
        return edges_set_open(graph)
    elseif set == :strand
        return edges_set_strand(graph)
    elseif set == :hyper
        return edges_set_hyper(graph)
    else
        throw(ArgumentError("Unknown edge set: $set"))
    end
end

function neighbors end
neighbors(graph; kwargs...) = neighbors(sort_nt(kwargs), graph, v)
neighbors(graph, v::AbstractVertex) = vertex_neighbors(graph, v)
neighbors(kwargs::NamedTuple{(:vertex,)}, graph) = vertex_neighbors(graph, kwargs.v)
neighbors(graph, e::AbstractEdge) = edge_neighbors(graph, e)
neighbors(kwargs::NamedTuple{(:edge,)}, graph) = edge_neighbors(graph, kwargs.e)

function vertex end
function edge end

"""
    all_vertices(graph)

Returns the vertices in the `graph`.
"""
function all_vertices end
@delegated interface=Network() all_vertices(graph)

"""
    all_edges(graph)

Returns the edges in the `graph`.
"""
function all_edges end
@delegated interface=Network() all_edges(graph)

"""
    edge_incidents(graph, e)

Returns the vertices connected by edge `e` in `graph`.
"""
function edge_incidents end
@delegated interface=Network() edge_incidents(graph, e)

"""
    vertex_incidents(graph, v)

Returns the edges connected to vertex `v` in `graph`.
"""
function vertex_incidents end
@delegated interface=Network() vertex_incidents(graph, e)

"""
    vertex_neighbors(graph, v)

Returns the vertices neighboring vertex `v` in the `graph`.
"""
function vertex_neighbors end
@delegated interface=Network() function vertex_neighbors(graph, v)
    fallback(vertex_neighbors)
    incident_edges = vertex_incidents(graph, v)
    neighbors = Set{vertex_type(graph)}()
    for edge in incident_edges
        edge_vertices = edge_incidents(graph, edge)
        for neighbor in edge_vertices
            if neighbor != v
                push!(neighbors, neighbor)
            end
        end
    end
    return neighbors
end

"""
    edge_neighbors(graph, e)

Returns the edges neighboring edge `e` in the `graph`.
"""
function edge_neighbors end
@delegated interface=Network() function edge_neighbors(graph, e)
    fallback(edge_neighbors)
    incident_vertices = edge_incidents(graph, e)
    neighbors = Set{edge_type(graph)}()
    for vertex in incident_vertices
        vertex_edges = vertex_incidents(graph, vertex)
        for neighbor in vertex_edges
            if neighbor != e
                push!(neighbors, neighbor)
            end
        end
    end
    return neighbors
end

# query methods with default implementation
"""
    vertex_type(graph)

Returns the type of vertices in the `graph`. Defaults to `Any`.
"""
function vertex_type end
@delegated interface=Network() function vertex_type(graph)
    fallback(vertex_type)
    return Any
end

"""
    edge_type(graph)

Returns the type of edges in the `graph`. Defaults to `Any`.
"""
function edge_type end
@delegated interface=Network() function edge_type(graph)
    fallback(edge_type)
    return Any
end

"""
    hasvertex(graph, v)

Returns `true` if vertex `v` exists in the `graph`.
"""
function hasvertex end
@delegated interface=Network() function hasvertex(graph, v)
    fallback(hasvertex)
    return v in vertices(graph)
end

"""
    hasedge(graph, e)

Returns `true` if edge `e` exists in the `graph`.
"""
function hasedge end
@delegated interface=Network() function hasedge(graph, e)
    fallback(hasedge)
    return e in edges(graph)
end

"""
    nvertices(graph)

Returns the number of vertices in the `graph`.
"""
function nvertices end
@delegated interface=Network() function nvertices(graph)
    fallback(nvertices)
    return length(vertices(graph))
end

"""
    nedges(graph)

Returns the number of edges in the `graph`.
"""
function nedges end
@delegated interface=Network() function nedges(graph)
    fallback(nedges)
    return length(edges(graph))
end

function edges_set_strand end
@delegated interface=Network() function edges_set_strand(graph)
    fallback(edges_set_strand)
    stranded_edges = Set{edge_type(graph)}()
    for edge in edges(graph)
        vertex_set = edge_incidents(graph, edge)
        if length(vertex_set) == 0
            push!(stranded_edges, edge)
        end
    end
    return stranded_edges
end

function edges_set_open end
@delegated interface=Network() function edges_set_open(graph)
    fallback(edges_set_open)
    stranded_edges = Set{edge_type(graph)}()
    for edge in edges(graph)
        vertex_set = edge_incidents(graph, edge)
        if length(vertex_set) == 1
            push!(stranded_edges, edge)
        end
    end
    return stranded_edges
end

function edges_set_hyper end
@delegated interface=Network() function edges_set_hyper(graph)
    fallback(edges_set_hyper)
    stranded_edges = Set{edge_type(graph)}()
    for edge in edges(graph)
        vertex_set = edge_incidents(graph, edge)
        if length(vertex_set) > 2
            push!(stranded_edges, edge)
        end
    end
    return stranded_edges
end

function vertex_at end
@delegated interface=Network() vertex_at(graph, tag)

function edge_at end
@delegated interface=Network() edge_at(graph, tag)

# mutating methods
"""
    addvertex!(graph, v)

Adds vertex `v` to the `graph`.
"""
function addvertex! end
@delegated interface=Network() addvertex!(graph, v)

"""
    addedge!(graph, e)

Adds edge `e` to the `graph`.
"""
function addedge! end
@delegated interface=Network() addedge!(graph, e)

"""
    rmvertex!(graph, v)

Removes vertex `v` from the `graph`.
"""
function rmvertex! end
@delegated interface=Network() rmvertex!(graph, v)

"""
    rmedge!(graph, e)

Removes edge `e` from the `graph`.
"""
function rmedge! end
@delegated interface=Network() rmedge!(graph, e)

"""
    setincident!(graph, v, e)

Links vertex `v` with edge `e` in the `graph`.
"""
function setincident! end
@delegated interface=Network() setincident!(graph, v, e)

"""
    unsetincident!(graph, v, e)

Unlinks vertex `v` from edge `e` in the `graph`.
"""
function unsetincident! end
@delegated interface=Network() unsetincident!(graph, v, e)

function prune_edges!(graph)
    for edge in edges_set_strand(graph)
        rmedge!(graph, edge)
    end
    return graph
end
