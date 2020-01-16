"""
    theta = DIVAnd_cvestimator(s,residual)

Computes the cross validation estimator
``(d-\\hat{d})^T \\mathbf R^{-1} (d-\\hat{d}) / ( \\mathbf 1^T \\mathbf R^{-1} \\mathbf 1)``
where the ``\\hat{d}`` is the analysis not using a data point.
"""
function DIVAnd_cvestimator(s, residual)
    # Take only points inside the domain into account
    obsin = .!s.obsout
    v1 = s.obsconstrain.R \ residual
    v2 = s.obsconstrain.R \ ones(size(residual))

    # operator a⋅b returns a scalar
    # unlike a'*b
    return (residual[obsin] ⋅ v1[obsin]) / sum(v2[obsin])
end

# Copyright (C) 2008-2019 Alexander Barth <barth.alexander@gmail.com>
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

# LocalWords:  fi DIVAnd pmn len diag CovarParam vel ceil moddim fracdim
