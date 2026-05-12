# Interfaces

Networks.jl uses [DelegatorTraits.jl](https://github.com/bsc-quantic/DelegatorTraits.jl) for method delegation: a type wrapping a `Network` implementor can "inherit" (in reality, delegate) its method definitions by just declaring:

```julia
DelegatorTraits.DelegatorTrait(::Network, ::MyWrapperType) = DelegatorTraits.DelegateToField{:the_field_name}()
```

Using [`DelegatorTraits.jl`](https://github.com/bsc-quantic/DelegatorTraits.jl) is completely optional and you can still do method delegation manually.

## Network

The `Network` interface abstracts a network or graph as a bipartite graph whose sets are the vertices and the edges.
As such, the main difference with the `Graphs.AbstractGraph` interface is that an edge has its own entity.
A type implementing the `Network` interface must implement the following methods:

| Required method          | Description                                 |
| :----------------------- | :------------------------------------------ |
| `all_vertices(g)`        | Returns the vertices list                   |
| `all_edges(g)`           | Returns the edges list                      |
| `edge_incidents(g, e)`   | Returns the vertices connected by edge `e`  |
| `vertex_incidents(g, v)` | Returns the edges conected to vertex `v`    |
| `vertex_neighbors(g, v)` | Returns the vertices neighboring vertex `v` |
| `edge_neighbors(g, e)`   | Returns the edges neighboring edge `e`      |

### Optional methods

The following methods have a default implementation or their implementation is optional.

| Method            | When should this method be defined? | Default definition        | Brief description                                      |
| :---------------- | :---------------------------------- | :------------------------ | :----------------------------------------------------- |
| `vertex_type(g)`  | If your vertex type is type-stable  | `Any`                     | Returns the type used for representing a vertex        |
| `edge_type(g)`    | If your edge type is type-stable    | `Any`                     | Returns the type used for representing an edge         |
| `hasvertex(g, v)` | If there is a more performant way   | `v in all_vertices(g)`    | Returns `true` if vertex `v` is present in network `g` |
| `hasedge(g, e)`   | If there is a more performant way   | `e in all_edges(g)`       | Returns `true` if edge `e` is present in network `e`   |
| `nvertices(g)`    | If there is a more performant way   | `length(all_vertices(g))` | Returns the number of vertices present in the network  |
| `nedges(g)`       | If there is a more performant way   | `length(all_edges(g))`    | Returns the number of edges present in the network     |

<!-- | `vertex_at(g, tag)` | If your type has some other way to refer to a vertex | _(undefined)_         | Returns the vertex related to `tag`                    |
| `edge_at(g, tag)`   | If your type has some other way to refer to an edge  | _(undefined)_         | Returns the edge related to `tag`                      | -->

### Mutating 

Methods that mutate a `Network` can be tricky to abstract and generalize,

| Method             | Brief description                   |
| :----------------- | :---------------------------------- |
| `addvertex!(g, v)` | Adds vertex `v` to network `g`      |
| `addedge!(g, e)`   | Adds edge `e` to network `g`        |
| `rmvertex!(g, v)`  | Removes vertex `v` from network `g` |
| `rmedge!(g, e)`    | Removes edge `e` from network `g`   |

<!-- | `link!(g, v, e)`    | Declares that edge `e` connects to vertex `v`   |
| `unlink!(g, v, e)`  | Undeclares that edge `e` connects to vertex `v` | -->

### Behaviors

#### Edge Persistence

The [`EdgePersistence`](@ref Networks.EdgePersistence) trait defines the behavior of edges when a vertex is removed. It currently has 3 traits:

- `PersistEdges`: edges are **never** removed implicitly (i.e. closed edges will transform into open edges).
- `RemoveEdges`: edges are **always** removed implicitly
- `PruneEdges`: edges are removed if left stranded (i.e. no other vertex is linked with it) (default)

## Taggable

WIP

## Attributeable

WIP
