using Base.Test
import divand

# test data for basic statistics
x = [1.,2.,3.,4.]
y = -[1.,2.,3.,4.]
sumx = sum(x)
sumx2 = sum(x.^2)

sumy = sum(y)
sumy2 = sum(y.^2)

sumxy = sum(x .* y)

meanx,stdx = divand.stats(sumx,sumx2,length(x))
meanx,meany,stdx,stdy,covar,corr = divand.stats(sumx,sumx2,sumy,sumy2,sumxy,length(x))

@test meanx ≈ mean(x)
@test stdx ≈ std(x)

@test corr ≈ -1

# DIVA fit

mincount = 50

xi,yi = divand.ndgrid(linspace(0,1,100),linspace(0,1,100))
mask = trues(size(xi))
pm = ones(size(xi)) / (xi[2,1]-xi[1,1])
pn = ones(size(xi)) / (yi[1,2]-yi[1,1])

lenx = .05;
leny = .05;
Nens = 1
distbin = 0:0.02:0.3
mincount = 100

srand(1234)
field = divand.random(mask,(pm,pn),(lenx,leny),Nens)


x = (xi[:],yi[:])
v = field[:]

distx,covar,corr,varx,count,stdcovar = divand.empiriccovarmean(
    x,v,distbin,mincount)

minlen = 0.001
maxlen = 0.1

var0opt = covar[1]
L = linspace(minlen,maxlen,100);

mu,K,len_scale = divand.divand_kernel(2,[1,2,1])

J(L) = sum(((covar - var0opt * K.(distx * len_scale/L))./stdcovar).^2)
Jmin,imin = findmin(J.(L))
lenopt = L[imin]


var0opt,lensopt,distx,covar,fitcovar = divand.fit_isotropic(
    x,v,distbin,mincount)


@test lensopt ≈ lenx rtol=0.2
@test var0opt ≈ 1 rtol=0.5


# port of DIVA fit from Fortran

A = readdlm(joinpath(dirname(@__FILE__),"..","data","testdata.txt")) :: Array{Float64,2}
n = size(A,1)
x = A[:,1]
y = A[:,2]
d = A[:,3]
weight = A[:,4]

# use all pairs
nsamp = 0
varbak,RL,distx,covar,fitcovar,stdcovar,dbinfo = divand.fitlen((x,y),d,weight,
                                                        nsamp)

# reference value are  from DIVA fit (Fortran version)

@test 1.5600269181532382 ≈ RL
@test 1.3645324462297863 ≈ dbinfo[:sn]
@test 25.431167981407523 ≈ varbak
@test 0.81123489141464233 ≈ dbinfo[:rqual]

# random samples
nsamp = 1000
varbak,RL,distx,covar,fitcovar,stdcovar,dbinfo = divand.fitlen((x,y),d,weight,
                                                        nsamp)

@test 1.5534502062950533 ≈ RL         rtol=0.01
@test 1.366798995586233 ≈ dbinfo[:sn] rtol=0.01
@test 25.449015845245974 ≈ varbak     rtol=0.01
@test 0.8042635826058093 ≈ dbinfo[:rqual] rtol=0.01

