
divand


# divand.jl documentation



```@docs
divand.divandrun
divand.divandgo
divand.divand_averaged_bg
divand.load_mask
divand.domain
divand.SDNMetadata
divand.save
divand.saveobs
divand.checkobs
divand.fit_isotropic
divand.fit
divand.smoothfilter
divand.Anam.loglin
divand.Anam.logit
divand.divadoxml
```

# Examples

To run the example, you need to install `PyPlot`.
In the folder `examples` of divand, you can run e.g. the example `divand_simple_example_1D.jl` by issuing:

```julia
# cd("/path/to/divand/examples")
include("divand_simple_example_1D.jl")
```

Replace `/path/to/divand/` by the installation directory of divand which is the output of `Pkg.dir("divand")` if you installed `divand` using Julias package manager.


# Vocabulary

urn_str


```@docs
Vocab.CFVocab
haskey(collection::Vocab.CFVocab,stdname)
Vocab.SDNCollection
Vocab.prefLabel
Vocab.altLabel
Vocab.notation
Vocab.find(c::Vocab.Concept,name,collection)
Vocab.description
Vocab.canonical_units
Vocab.splitURL
```


# Information for developpers

## Update the documentation

Install

```julia
Pkg.add("Documenter")
```