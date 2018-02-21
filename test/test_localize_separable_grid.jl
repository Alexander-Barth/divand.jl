using Base.Test


I = localize_separable_grid(([4],),ones(10),(2*collect(1:10),))
@test I[1] ≈ 2.

# 2D with one point

x1,y1 = ndgrid(2 * collect(1:5),collect(1:6))
x = (x1,y1)
xi = (3,3)
mask = trues(x1);

I = localize_separable_grid(xi,mask,x)

@test I ≈ [1.5; 3]


# 2D with 2 points

x1,y1 = ndgrid(2 * collect(1:5),collect(1:6))
x = (x1,y1)
xi = ([3,4],[3,5])
mask = trues(x1);

I = localize_separable_grid(xi,mask,x)

@test I ≈ [1.5 2.0; 3. 5. ]


# 2D with 1 point outside

x1,y1 = ndgrid(linspace(0.5,1,50),linspace(0.,1,30));
x = (x1,y1)
xi = ([0.2],[0.5])
mask = trues(x1);
I = localize_separable_grid(xi,mask,x)
@test I[1] < 1