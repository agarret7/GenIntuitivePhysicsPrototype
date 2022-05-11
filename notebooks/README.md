# Running Notebooks

Read in order.

```
1_inertia.ipynb
2_Gravity.ipynb
3_Collisions.ipynb
```

To start, in a shell run:
```shell
julia --project -e "using Pkg; Pkg.instantiate(); using IJulia; notebook()
```