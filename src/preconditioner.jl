import Base: \, *, A_ldiv_B!, A_mul_B!

struct Preconditioner
    ml::MultiLevel
end

aspreconditioner(ml::MultiLevel) = Preconditioner(ml)

\(p::Preconditioner, b) = solve(p.ml, b, maxiter = 1, tol = 1e-12)
*(p::Preconditioner, b) = p.ml.levels[1].A * x

A_ldiv_B!(x, p::Preconditioner, b) = copy!(x, p \ b)
A_mul_B!(b, p::Preconditioner, x) = A_mul_B!(b, p.ml.levels[1].A, x)
