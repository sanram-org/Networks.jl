struct Attributeable <: Interface end

# NOTE the API has been designed to have dynamic attrs that can be saved in a `Dict{Symbol,Any}`, but there should be
# nothing holding back to have static attributes. perhaps for type-stability we may need to use a `AttrKey{T}` type on
# which to dispatch or have a `AttributeTypeTrait` with `StaticAttribute` and `DynamicAttribute` traits.

# dispatching methods
function attrs end
attrs(tn) = attrs_global(tn)
attrs(tn, vertex::AbstractVertex) = attrs_vertex(tn, vertex)
attrs(tn, edge::AbstractEdge) = attrs_edge(tn, edge)

function getattr end
getattr(tn, key) = getattr_global(tn, key)
getattr(tn, vertex::AbstractVertex, key) = getattr_vertex(tn, vertex, key)
getattr(tn, edge::AbstractEdge, key) = getattr_edge(tn, edge, key)

getattr(tn, key, default) = hasattr(tn, key) ? getattr(tn, key) : default
getattr(tn, vertex::AbstractVertex, key, default) = hasattr(tn, vertex, key) ? getattr(tn, vertex, key) : default
getattr(tn, edge::AbstractEdge, key, default) = hasattr(tn, edge, key) ? getattr(tn, edge, key) : default

function setattr! end
setattr!(tn, key, value) = setattr_global!(tn, key, value)
setattr!(tn, vertex::AbstractVertex, key, value) = setattr_vertex!(tn, vertex, key, value)
setattr!(tn, edge::AbstractEdge, key, value) = setattr_edge!(tn, edge, key, value)

function hasattr end
hasattr(tn, key) = hasattr_global(tn, key)
hasattr(tn, vertex::AbstractVertex, key) = hasattr_vertex(tn, vertex, key)
hasattr(tn, edge::AbstractEdge, key) = hasattr_vertex(tn, edge, key)

# query methods
function attrs_global end
@delegated interface=Attributeable() attrs_global(graph)

function attrs_vertex end
@delegated interface=Attributeable() attrs_vertex(graph, v)

function attrs_edge end
@delegated interface=Attributeable() attrs_edge(graph, e)

function getattr_global end
@delegated interface=Attributeable() function getattr_global(graph, key)
    fallback(getattr_global)
    return getindex(attrs_global(graph), key)
end

function getattr_vertex end
@delegated interface=Attributeable() function getattr_vertex(graph, v, key)
    fallback(getattr_vertex)
    return getindex(attrs_vertex(graph, v), key)
end

function getattr_edge end
@delegated interface=Attributeable() function getattr_edge(graph, e, key)
    fallback(getattr_edge)
    return getindex(attrs_edge(graph, e), key)
end

function hasattr_global end
@delegated interface=Attributeable() function hasattr_global(graph, key)
    fallback(hasattr_global)
    return getindex(attrs_global(graph), key)
end

function hasattr_vertex end
@delegated interface=Attributeable() function hasattr_vertex(graph, v, key)
    fallback(hasattr_vertex)
    return getindex(attrs_vertex(graph, v), key)
end

function hasattr_edge end
@delegated interface=Attributeable() function hasattr_edge(graph, e, key)
    fallback(hasattr_edge)
    return getindex(attrs_edge(graph, e), key)
end

# mutating methods
function setattr_global! end
@delegated interface=Attributeable() setattr_global!(graph, key, value)

function setattr_vertex! end
@delegated interface=Attributeable() setattr_vertex!(graph, v, key, value)

function setattr_edge! end
@delegated interface=Attributeable() setattr_edge!(graph, e, key, value)

function delattr_global! end
@delegated interface=Attributeable() delattr_global!(graph, key)

function delattr_vertex! end
@delegated interface=Attributeable() delattr_vertex!(graph, v, key)

function delattr_edge! end
@delegated interface=Attributeable() delattr_edge!(graph, e, key)
