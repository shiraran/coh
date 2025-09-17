import Foundation

struct RNG {
    private var generator: SeededGenerator

    init(seed: UInt64) {
        generator = SeededGenerator(seed: seed)
    }

    mutating func nextInt(upperBound: Int) -> Int {
        Int.random(in: 0..<upperBound, using: &generator)
    }
}

private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var result = state
        result = (result ^ (result >> 30)) &* 0xBF58476D1CE4E5B9
        result = (result ^ (result >> 27)) &* 0x94D049BB133111EB
        return result ^ (result >> 31)
    }
}
