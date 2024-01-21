using QuantumClifford
using QuantumClifford: StabMixture, rowdecompose, PauliChannel, mul_left!, mul_right!, pauli_measure!
using Test
using InteractiveUtils
using Random

##

@testset "Pauli decomposition into destabilizers" begin
    for n in [1,2,63,64,65,66,300]
        p = random_pauli(n; nophase=true)
        s = random_destabilizer(n)
        phase, b, c = rowdecompose(p,s)
        p0 = zero(p)
        for (i,f) in pairs(b)
            f && mul_right!(p0, destabilizerview(s), i)
        end
        for (i,f) in pairs(c)
            f && mul_right!(p0, stabilizerview(s), i)
        end
        @test (im)^phase*p0 == p
    end
end

##

@testset "PauliChannel T gate ^4 = Id" begin
    tgate = pcT
    state = StabMixture(S"X")

    apply!(state, tgate)
    apply!(state, tgate)
    apply!(state, tgate)
    apply!(state, tgate)

    @test state.destabweights |> values |> collect == [1]
    @test state.destabweights |> keys |> collect == [([1],[1])]
end

@testset "Pauli Expectation for T-state" begin
    tgate = pcT
    state = StabMixture(S"X")
    apply!(state, tgate)
    @test expect(P"X", state) ≈ sqrt(1/2)
end

@testset "Measurement" begin
    tgate = pcT
    state = StabMixture(S"X")
    apply!(state, tgate)
    _, res1 = pauli_measure!(state, PauliMeasurement(P"X"))
    _, res2 = pauli_measure!(state, PauliMeasurement(P"X"))
    @test res1 == res2
end

##

@test_throws ArgumentError StabMixture(S"XX")
@test_throws ArgumentError PauliChannel(((P"X", P"Z"), (P"X", P"ZZ")), (1,2))
@test_throws ArgumentError PauliChannel(((P"X", P"Z"), (P"X", P"Z")), (1,))
@test_throws ArgumentError UnitaryPauliChannel((P"X", P"ZZ"), (1,2))
@test_throws ArgumentError UnitaryPauliChannel((P"X", P"Z"), (1,))
