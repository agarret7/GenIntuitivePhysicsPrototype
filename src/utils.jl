#################
### Datatypes ###
#################

Vec2 = Tuple{<:Real, <:Real}

function Base.:+(v1::Vec2, v2::Vec2) :: Vec2
    return (v1[1] + v2[1], v1[2] + v2[2])
end

function Base.:*(a::Real, v::Vec2) :: Vec2
    return (a * v[1], a * v[2])
end

Base.:*(v::Vec2, a::Real) = a * v  # commutativity

function Base.:/(v::Vec2, a::Real) :: Vec2
    @assert a != 0
    return (v[1] / a, v[2] / a)
end

function Base.:-(v::Vec2) :: Vec2
    return (-v[1], -v[2])
end

function l2norm(v::Vec2)
    return (v[1]^2 + v[2]^2)^(1/2)
end

function dot(v1::Vec2, v2::Vec2) :: Real
    return v1[1]*v2[1] + v1[2]*v2[2]
end


struct State
    position :: Vec2
    velocity :: Vec2
    acceleration :: Vec2
end

function get_positions(states::Vector{State}) :: Vector{Vec2}
    return [state.position for state in states]
end

function get_velocities(states::Vector{State}) :: Vector{Vec2}
    return [state.velocity for state in states]
end

function get_accelerations(states::Vector{State}) ::Vector{Vec2}
    return [state.acceleration for state in states]
end

Bounds{T <: Real} = NamedTuple{(:xmin,:ymin,:xmax,:ymax), NTuple{4,T}}


################
### plotting ###
################

using PyPlot

function init_occluder_scene(obs, subtitle=nothing;
                             plot_bounds = (xmin=-0.5,ymin=-1,xmax=1.5,ymax=1),
                             occluder_bounds = (xmin=0,ymin=-0.3,xmax=1,ymax=0.3))
    fig, ax = subplots()

    plot_xmin = plot_bounds[:xmin]
    plot_ymin = plot_bounds[:ymin]
    plot_xmax = plot_bounds[:xmax]
    plot_ymax = plot_bounds[:ymax]
    ax.set_xlim(plot_xmin, plot_xmax)
    ax.set_ylim(plot_ymin, plot_ymax)
    if isnothing(subtitle)
        ax.set_title("Dynamics Model")
    else
        ax.set_title("Dynamics Model: $subtitle")
    end
    ax.set_xlabel("X")
    ax.set_ylabel("Y")

    # draw occluder
    xmin = occluder_bounds[:xmin]
    ymin = (occluder_bounds[:ymin] - plot_ymin) / (plot_ymax - plot_ymin)
    xmax = occluder_bounds[:xmax]
    ymax = (occluder_bounds[:ymax] - plot_ymin) / (plot_ymax - plot_ymin)
    # ax.axvspan(xmin, xmax, ymin, ymax, edgecolor="black", facecolor="gray", alpha=0.25)

    # draw observed end point
    if !isnothing(obs)
        ax.scatter(obs[1], obs[2], s=300, marker="*", c="red", label="Observed Endpoint")
        ax.legend()
    end

    return (fig, ax)
end

# plotting defaults
_DEFAULT_TRACE_COLOR = "black"

function draw_states!(ax, states; color=_DEFAULT_TRACE_COLOR)
    positions = get_positions(states)
    xs = [p[1] for p in positions]
    ys = [p[2] for p in positions]
    ax.scatter(xs, ys, c=color, alpha=0.2)
    ax.plot(xs, ys, ls="dashed", c=color, alpha=0.2)
end

function draw_trace!(ax, tr; color=_DEFAULT_TRACE_COLOR)
    states = Gen.get_retval(tr)
    draw_states!(ax, states; color=color)
end


##################
### displaying ###
##################

function display_source(source_f::String)
    source = read(source_f, String)
    stream = IOBuffer()
    stylesheet(stream, MIME("text/html"))
    highlight(stream, MIME("text/html"), source, Lexers.JuliaLexer)
    display("text/html", read(seekstart(stream), String))
end