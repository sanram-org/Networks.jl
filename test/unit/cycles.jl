using Test
using Networks
using Networks: Vertex, Edge, setincident!

@testset "cycle_basis" begin
    # 2x3 grid
    g = IncidentNetwork{Vertex{Tuple{Int,Int}},Edge{Int}}()

    for i in 1:2, j in 1:3
        addvertex!(g, Vertex((i, j)))
    end

    addedge!(g, Edge(1))
    setincident!(g, Vertex((1, 1)), Edge(1))
    setincident!(g, Vertex((1, 2)), Edge(1))

    addedge!(g, Edge(2))
    setincident!(g, Vertex((1, 2)), Edge(2))
    setincident!(g, Vertex((1, 3)), Edge(2))

    addedge!(g, Edge(3))
    setincident!(g, Vertex((1, 1)), Edge(3))
    setincident!(g, Vertex((2, 1)), Edge(3))

    addedge!(g, Edge(4))
    setincident!(g, Vertex((1, 2)), Edge(4))
    setincident!(g, Vertex((2, 2)), Edge(4))

    addedge!(g, Edge(5))
    setincident!(g, Vertex((1, 3)), Edge(5))
    setincident!(g, Vertex((2, 3)), Edge(5))

    addedge!(g, Edge(6))
    setincident!(g, Vertex((2, 1)), Edge(6))
    setincident!(g, Vertex((2, 2)), Edge(6))

    addedge!(g, Edge(7))
    setincident!(g, Vertex((2, 2)), Edge(7))
    setincident!(g, Vertex((2, 3)), Edge(7))

    cycles = Set(Set.(Networks.cycle_basis(g, Vertex((1, 1)))))
    ref_cycles = Set([Set(Vertex.([(1, 1), (1, 2), (2, 2), (2, 1)])), Set(Vertex.([(1, 2), (1, 3), (2, 3), (2, 2)]))])

    @test length(cycles) == 2
    @test issetequal(cycles, ref_cycles)
end
