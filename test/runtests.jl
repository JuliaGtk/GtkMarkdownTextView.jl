using GtkMarkdownTextView, Test
using Gtk

@testset "MarkdownTextView" begin
    
    w = GtkWindow("")

    md = "# test\n ## test\n*test* test **test**\n - test\n\ttest"
    v = MarkdownTextView(md)
    push!(w,v)
    showall(w)
    sleep(1)
    destroy(w)

end