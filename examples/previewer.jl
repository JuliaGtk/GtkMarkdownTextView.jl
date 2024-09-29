using Gtk4, GtkMarkdownTextView, Markdown

w = GtkWindow("GtkMarkdownTextView example")
Gtk4.default_size(w, 400, 600)
p = GtkPaned(:h)
w[] = p

md = """
This widget displays Markdown, including **bold**, *italics*, and `code`.

It also:
- displays
- bulleted
- lists

## Further remarks

Blah blah blah
"""

tv = GtkTextView(; wrap_mode=Gtk4.WrapMode_WORD)
tv.buffer.text = md
p[1] = tv

v = MarkdownTextView(md)
p[2] = v

signal_connect(tv.buffer, "changed") do buffer
    v.buffer.text = ""
    GtkMarkdownTextView.insert_MD!(v.buffer, Markdown.parse(buffer.text))
end

show(w)
