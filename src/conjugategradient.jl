
"""
x,success,niter = conjugategradient(fun,b,x0,tol,maxit,pc);

Solve a linear system with the preconditioned conjugated-gradient method:
A x = b
where `A` is a symmetric positive defined matrix and `b` is a vector. The function `fun(x)` represents `A*x`.

# Optional input arguments
* `x0`: starting vector for the interations
* `tol`: tolerance on  |Ax-b| / |b|
* `maxit`: maximum of interations
* `pc`: the preconditioner. The functions `pc(x)` should return M⁻¹ x (the inverse of M times x) where `M` is a symmetric positive defined matrix. Effectively, the system E⁻¹ A (E⁻¹)ᵀ (E x) = E⁻¹ b is solved for (E x) where E Eᵀ = M. Ideally, M should this be similar to A, so that E⁻¹ A (E⁻¹)ᵀ is close to the identity matrix.

# Output
* `x`: the solution
* `success`: true if the interation converged (otherwise false)
* `niter`: the number of iterations
"""


# It provides also an approximation of A:
# A \sim Q*T*Q'

# J(x) = 1/2 (x' b - x' A x)
# ∇ J = b - A x
# A x = b - ∇ J
# b = ∇ J(0)

# the columns of Q are the Lanczos vectors

function conjugategradient(fun,b; pc = x -> x, x0 = zeros(size(b)), tol = 1e-6, maxit = min(size(b,1),20),
                           minit = 0,
                           progress = (iter,x,r,tol2,fun,b) -> nothing
                           )
    #, renorm = false)

	
#	gc_enable(false)

	
    success = false
    n = length(b);

    bb = b ⋅ b

    if bb == 0
	    
        gc_enable(true)
        return zeros(size(b)),true,0
    end

    # relative tolerance
    tol2 = tol^2

    # absolute tolerance
    tol2 = tol2 * bb

    # delta = [];
    # gamma = [];
    # q = NaN*zeros(n,1);

    #M = inv(invM);
    #E = chol(M);


    # initial guess
    x = x0::Array{Float64,1};

    # gradient at initial guess
	
	#@code_warntype fun(x)
    Ap=fun(x)::Array{Float64,1}
    r = b - Ap::Array{Float64,1};

    # quick exit
    if r⋅r < tol2
	   
        gc_enable(true)

        return x,true,0
    end



    # apply preconditioner
    z = pc(r)::Array{Float64,1};

    # first search direction == gradient
    p = z;

    # compute: r' * inv(M) * z (we will need this product at several
    # occasions)

    # ⋅ is the dot vector product and returns a scalar
    zr_old = r ⋅ z;

    # r_old: residual at previous iteration
    r_old = r;

    alpha = zeros(Float64,maxit)
    beta = zeros(Float64,maxit+1)

    k = 0

    for k=1:maxit
	
# try axpy! ?
        # if k <= n && nargout > 1
        #     # keep at most n vectors
        #     Q(:,k) = r/sqrt(zr_old);
        # end

        # compute A*p
        Ap = fun(p)::Array{Float64,1};

        # how far do we need to go in direction p?
        # alpha is determined by linesearch

        alpha[k] = zr_old / (p ⋅ Ap);

        # get new estimate of x
        #x = x + alpha[k]*p;
		#@show size(x)[1]
		#x=BLAS.axpy!(size(x)[1],alpha[k],p,1,x,1)
		x=BLAS.axpy!(alpha[k],p,x)

        # recompute gradient at new x. Could be done by
        # r = b-fun(x);
        # but this does require an new call to fun
		#
        #r = r - alpha[k]*Ap;
		alphak=-alpha[k]
        #r=BLAS.axpy!(size(r)[1],-alpha[k],Ap,1,r,1)
		r=BLAS.axpy!(alphak,Ap,r)
        #if renorm
        #    r = r - Q(:,1:k) * Q(:,1:k)' * r ;
        #end

        

        progress(k,x,r,tol2,fun,b)

        if mod(k,10)==1
            @show k, r ⋅ r,tol2,size(r)
        end

        if r ⋅ r < tol2 && k >= minit
            success = true
            @show k
            break
        end
#JMB moved after the test, no need to calculate further values if r is small enough
# apply pre-conditionner
        z = pc(r)::Array{Float64,1};

        zr_new = r ⋅ z;
		
        #Fletcher-Reeves
        beta[k+1] = zr_new / zr_old;
        #Polak-Ribiere
        #beta[k+1] = r'*(r-r_old) / zr_old;
        #Hestenes-Stiefel
        #beta[k+1] = r'*(r-r_old) / (p'*(r-r_old));
        #beta[k+1] = r'*(r-r_old) / (r_old'*r_old);


        # norm(p)
        p = z + beta[k+1]*p;
        zr_old = zr_new;
        r_old = r;

    end

    gc_enable(true)

    return x,success,k

    #disp('alpha and beta')
    #figure,plot(beta(2:end))
    #rg(alpha)
    #rg(beta(2:end))

    # if nargout > 1
    #     kmax = size(Q,2);

    #     delta[1] = 1/alpha[1];

    #     #delta[1] - Q[:,1]'*invM*A*invM*Q[:,1]


    #     for k=1:kmax-1
    #         delta[k+1] = 1/alpha[k+1] + beta[k+1]/alpha[k];
    #         gamma[k] = -sqrt(beta[k+1])/alpha[k];
    #     end

    #     T = sparse([1:kmax   1:kmax-1 2:kmax  ],...
    #         [1:kmax   2:kmax   1:kmax-1],...
    #         [delta    gamma    gamma]);

    #     diag.iter = k;
    #     diag.relres = sqrt(r'*r);
    # end

end

# Copyright (C) 2004 Alexander Barth 			<a.barth@ulg.ac.be>
#                         Jean-Marie Beckers 	<jm.beckers@ulg.ac.be>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, see <http://www.gnu.org/licenses/>.
