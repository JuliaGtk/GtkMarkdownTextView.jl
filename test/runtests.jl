using GtkMarkdownTextView, Test
using Gtk4

@testset "MarkdownTextView" begin
    
    w = GtkWindow("")

    md = """
IOBuffer([data::AbstractVector{UInt8}]; keywords...) -> IOBuffer
Create an in-memory I/O stream, which may optionally operate on a pre-existing array.
It may take optional keyword arguments:
- `read`, `write`, `append`: restricts operations to the buffer; see `open` for details.
- `truncate`: truncates the buffer size to zero length.
- `maxsize`: specifies a size beyond which the buffer may not be grown.
- `sizehint`: suggests a capacity of the buffer (`data` must implement `sizehint!(data, size)`).
When `data` is not given, the buffer will be both readable and writable by default.
"""


    v = MarkdownTextView(md)
    push!(w,v)
    show(w)
    sleep(1)
    destroy(w)

end
