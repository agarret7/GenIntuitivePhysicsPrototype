# MCS Intuitive Physics Prototype

### Introduction

This repository contains 3 notebooks in `./notebooks`:

1. Inertia
2. Gravity
3. Collisions

To run these notebooks, in shell run:
```shell
julia --project -e "using Pkg; Pkg.instantiate(); using IJulia; notebook(dir = joinpath(@__DIR__, \"notebooks\"))"
```

We leverage a random force dynamics model that integrates simple Newtonian physics with probabilistic modeling to derive physically plausible trajectories from final-state observations.

### Model
```julia
"""
Simple discrete integration. Can be replaced with something like PyBullet.
"""
function dynamics_sim(prev_state::State, rand_a::Vec2; const_a::Vec2=(0,0), ΔT::Real=1)
    prev_v = prev_state.velocity
    prev_x = prev_state.position

    new_a = const_a + rand_a
    new_v = prev_v + new_a * ΔT
    new_x = prev_x + new_v * ΔT
    new_state = State(new_x, new_v, new_a)

    return new_state
end

"""
Models the trajectory of a particle across `T` time steps, starting at `init_state`.
The particle is subject to `const_a` acceleration, plus a normally distributed acceleration at each time step.
The end position is then observed.
"""
@gen function dynamics_model(T::Int, init_state::State, const_a::Vec2, hypers::Hypers)
    # initialization
    states = Vector{State}(undef, T+1)
    states[1] = init_state

    # run dynamics
    for t in 1:T
        # model randomness
        rand_a = {t} ~ dynamics_randomness(states[t], hypers.accel_std)

        # run simulation
        states[t+1] = dynamics_sim(states[t], rand_a; const_a = const_a)
    end

    # object emerges
    final_pos = states[end].position
    {:obs} ~ obs_randomness(final_pos, hypers.obs_std)

    return states
end
```