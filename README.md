# GtkMarkdownTextView

[![Build Status](https://travis-ci.org/jonathanBieler/GtkMarkdownTextView.jl.svg?branch=master)](https://travis-ci.org/jonathanBieler/GtkMarkdownTextView.jl)

[![Coverage Status](https://coveralls.io/repos/jonathanBieler/GtkMarkdownTextView.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/jonathanBieler/GtkMarkdownTextView.jl?branch=master)

A Widget to display Markdown formatted text:

```julia
w = GtkWindow("")

md = "# test\n ## test\n*test* test **test**\n - test\n\ttest"
v = MarkdownTextView(md)
push!(w,v)
showall(w)
```
