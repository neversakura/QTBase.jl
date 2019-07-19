struct DenseHamiltonian{T <: Complex} <: AbstractDenseHamiltonian{T}
    op::LinearOperator{T}
    u_cache::Matrix{T}
end

function DenseHamiltonian(funcs, mats)
    cache = zeros(eltype(mats[1]), size(mats[1]))
    operator = AffineOperator(funcs, mats)
    DenseHamiltonian(operator, cache)
end

function (h::DenseHamiltonian)(t::Real)
    fill!(h.u_cache, 0.0)
    h.op(h.u_cache, t)
    h.u_cache
end


function (h::DenseHamiltonian)(du, u::Matrix{T}, p::Real, t::Real) where T<:Complex
    H = h(t)
    gemm!('N', 'N', -1.0im * p, H, u, 1.0 + 0.0im, du)
    gemm!('N', 'N', 1.0im * p, u, H, 1.0 + 0.0im, du)
end


function (h::DenseHamiltonian)(du, u::Vector{T}, p::Real, t::Real) where T<:Complex
    H = h(t)
    mul!(du, -1.0im * p * H, u)
end


function p_copy(h::DenseHamiltonian)
    DenseHamiltonian(h.op, zeros(eltype(h.u_cache), size(h.u_cache)))
end

function eigen_decomp(h::AbstractDenseHamiltonian, t; level = 2)
    H = h(t)
    w, v = eigen!(Hermitian(H))
    w[1:level], v[:, 1:level]
end

function eigen_decomp(h::AbstractDenseHamiltonian)
    eigen!(Hermitian(h.u_cache))
end
