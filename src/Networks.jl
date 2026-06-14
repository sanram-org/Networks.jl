module Networks

using DelegatorTraits
import DelegatorTraits: DelegatorTrait, ImplementorTrait

include("Utils.jl")

include("Interface.jl")
export Network

export vertices, all_vertices, vertex_at, edge_incidents, vertex_type, hasvertex, nvertices, addvertex!, rmvertex!
export edges, all_edges, edge_at, vertex_incidents, edge_type, hasedge, nedges, addedge!, rmedge!
export setincident!, unsetincident!
export edges_set_strand, edges_set_open, edges_set_hyper
export neighbors, vertex_neighbors, edge_neighbors

include("Implementations/IncidentNetwork.jl")
export IncidentNetwork

include("Implementations/SimpleNetwork.jl")
export SimpleNetwork

include("Algorithms/cycles.jl")

end # module Networks
