struct Taggable <: Interface end

# traits
# WARN experimental
abstract type TagKind end
struct VertexTagKind <: TagKind end
struct EdgeTagKind <: TagKind end

function tag_kind end
tag_kind(_::T) where {T} = tag_kind(T)

# TODO is this correct?
tag_kind(::Type{<:AbstractVertex}) = VertexTagKind()
tag_kind(::Type{<:AbstractEdge}) = EdgeTagKind()

# dispatching methods
# WARN experimental
function tags end
function tag end

function hastag end
hastag(graph, tag) = hastag(graph, tag, TagKind(tag))
hastag(graph, tag, ::VertexTagKind) = has_vertex_tag(graph, tag)
hastag(graph, tag, ::EdgeTagKind) = has_edge_tag(graph, tag)

function tag_at end
### TODO add methods based on trait instead of abstract type?
tag_at(graph, v::AbstractVertex) = tag_at_vertex(graph, v)
tag_at(graph, e::AbstractEdge) = tag_at_edge(graph, e)

function tag! end
function untag! end
function replace_tag! end
replace_tag!(graph, old, new) = replace_tag!(graph, old, new, TagKind(old), TagKind(new))
replace_tag!(graph, old, new, ::VertexTagKind, ::VertexTagKind) = replace_vertex_tag!(graph, old, new)
replace_tag!(graph, old, new, ::EdgeTagKind, ::EdgeTagKind) = replace_edge_tag!(graph, old, new)
replace_tag!(graph, old, new, ::TagKind, ::TagKind) = throw(MethodError(replace_tag!, (graph, old, new)))

# query methods
function vertex_tags end
@delegated interface=Taggable() vertex_tags(graph)

function edge_tags end
@delegated interface=Taggable() edge_tags(graph)

function has_vertex_tag end
@delegated interface=Taggable() has_vertex_tag(graph, tag)

function has_edge_tag end
@delegated interface=Taggable() has_edge_tag(graph)

# TODO replace for `vertex_tag_at` and `edge_tag_at`?
function tag_at_vertex end
@delegated interface=Taggable() tag_at_vertex(graph, v)

function tag_at_edge end
@delegated interface=Taggable() tag_at_edge(graph, e)

# mutating methods
function tag_vertex! end
@delegated interface=Taggable() tag_vertex!(graph, v, tag)

function tag_edge! end
@delegated interface=Taggable() tag_edge!(graph, e, tag)

function untag_vertex! end
@delegated interface=Taggable() untag_vertex!(graph, v)

function untag_edge! end
@delegated interface=Taggable() untag_edge!(graph, e)

function replace_vertex_tag! end
@delegated interface=Taggable() replace_vertex_tag!(graph, old, new)

function replace_edge_tag! end
@delegated interface=Taggable() replace_edge_tag!(graph, old, new)
