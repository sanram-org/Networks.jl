# Network interface

> [!NOTE]
> Networks.jl uses [DelegatorTraits.jl](https://github.com/bsc-quantic/DelegatorTraits.jl) for method delegation: a type wrapping a `Network` implementor can "inherit" (in reality, delegate) its method definitions by just declaring:
>
> ```julia
> DelegatorTraits.DelegatorTrait(::Network, ::MyWrapperType) = DelegatorTraits.DelegateToField{:the_field_name}()
> ```
>
> Using [`DelegatorTraits.jl`](https://github.com/bsc-quantic/DelegatorTraits.jl) is completely optional and you can still do method delegation manually.

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

## Optional methods

The following methods have a default implementation or their implementation is optional.

| Method            | When should this method be defined? | Default definition        | Brief description                                      |
| :---------------- | :---------------------------------- | :------------------------ | :----------------------------------------------------- |
| `vertex_type(g)`  | If your vertex type is type-stable  | `Any`                     | Returns the type used for representing a vertex        |
| `edge_type(g)`    | If your edge type is type-stable    | `Any`                     | Returns the type used for representing an edge         |
| `hasvertex(g, v)` | If there is a more performant way   | `v in all_vertices(g)`    | Returns `true` if vertex `v` is present in network `g` |
| `hasedge(g, e)`   | If there is a more performant way   | `e in all_edges(g)`       | Returns `true` if edge `e` is present in network `e`   |
| `nvertices(g)`    | If there is a more performant way   | `length(all_vertices(g))` | Returns the number of vertices present in the network  |
| `nedges(g)`       | If there is a more performant way   | `length(all_edges(g))`    | Returns the number of edges present in the network     |

The following methods are useful for extending on your own types if you compose on top of a [`Network`](@ref) implementation and you need to refer to a vertex or edge through your own tag system.

| Method            | Description                          |
| :---------------- | :----------------------------------- |
| `vertex_at(g, t)` | Returns the vertex associated to `t` |
| `edge_at(g, t)`   | Returns the vertex associated to `t` |

## Mutating methods

Methods that mutate a `Network` can be tricky to abstract and generalize, specially due to the different nature of an "edge" depending on the [`MatrixRepresentation`](@ref Networks.MatrixRepresentation).

| Method             | Brief description                   |
| :----------------- | :---------------------------------- |
| `addvertex!(g, v)` | Adds vertex `v` to network `g`      |
| `rmvertex!(g, v)`  | Removes vertex `v` from network `g` |
| `addedge!(g, e)`   | Adds edge `e` to network `g`        |
| `rmedge!(g, e)`    | Removes edge `e` from network `g`   |

If the network is based on a [`IncidentMatrix`](@ref Networks.IncidentMatrix), then [`addedge!`](@ref) and [`rmedge!`](@ref) won't link the vertices and the edges. In such case, the network type must implement these two extra functions:

| Method                    | Brief description                                                     |
| :------------------------ | :-------------------------------------------------------------------- |
| `setincident!(g, v, e)`   | Sets edge `e` and vertex `v` as incident (only if `IncidentMatrix`)   |
| `unsetincident!(g, v, e)` | Unsets edge `e` and vertex `v` as incident (only if `IncidentMatrix`) |

Finally, since on a network based on a [`IncidentMatrix`](@ref Networks.IncidentMatrix) can accept edges that connect no vertices, automatic edge removal on [`rmvertex!`](@ref) might be illdefined. This behavior can be configured using the [`EdgePersistence`](@ref Networks.EdgePersistence) trait.

### Matrix Representation

The [`MatrixRepresentation`](@ref Networks.MatrixRepresentation) traits defines the underlying mathematical construct used for representing the network.

- `AdjacentMatrix`: uses a ``V \times V`` matrix whose elements are non-zero if its corresponding vertices are directly connected by an edge.
  - Most popular representation.
  - Vertices are explicitly represented, edges are implicit.
- `IncidentMatrix`: uses a ``V \times E`` matrix whose elements are non-zero if its corresponding vertex-edge pair are connected.
  - Supports open-edges, hyper-edges and multi-edges.
  - Both vertices and edges are explicitly represented.

### Edge Persistence

The [`EdgePersistence`](@ref Networks.EdgePersistence) trait defines the behavior of edges when a vertex is removed.

- `PersistEdges`: edges are **never** removed implicitly (i.e. closed edges will transform into open edges).
- `RemoveEdges`: edges are **always** removed implicitly
- `PruneEdges`: edges are removed if left stranded (i.e. no other vertex is linked with it) (default)
