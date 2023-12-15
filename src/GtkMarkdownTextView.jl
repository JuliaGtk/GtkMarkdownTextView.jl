module GtkMarkdownTextView

    using Gtk4
    import Gtk4: _GtkTextIter, create_tag, apply_tag
    import Gtk4.GLib: gobject_move_ref, GObject

    using Markdown
    
    export MarkdownTextView, MarkdownColors
    
    struct MarkdownColors
        font_size::Int
        color::String
        background::String
        highlight_color::String
        highlight_background::String
    end
    
    MarkdownColors() =  MarkdownColors(13, "#000", "#fff", "#111", "#eee")
    
    mutable struct MarkdownTextView <: GtkTextView
        handle::Ptr{GObject}
        view::GtkTextView
        buffer::GtkTextBuffer

        function MarkdownTextView(m::Markdown.MD, prelude::String, mc::MarkdownColors = MarkdownColors(); kwargs...)
            
            buffer = GtkTextBuffer()
            buffer.text = prelude
            view = GtkTextView(buffer; kwargs...)
            
            style_css(view, 
                "window, view, textview, buffer, text {
                    background-color: $(mc.background);
                    color: $(mc.color);
                    font-family: Monaco, Consolas, Courier, monospace;
                    margin:0px;
                }"
            )

            #set_gtk_property!(view, :margin_left, 1)
            view.monospace = true
            view.wrap_mode = true

            fs = mc.font_size

            create_tag(buffer, "normal",    font = "$fs")
            create_tag(buffer, "h1",        font = "bold $(fs+3)")
            create_tag(buffer, "h2",        font = "bold $(fs+2)")
            create_tag(buffer, "h3",        font = "bold $(fs+1)")
            create_tag(buffer, "h4",        font = "bold $(fs)")
            create_tag(buffer, "h5",        font = "$(fs)")
            create_tag(buffer, "h6",        font = "$(fs-1)")
            create_tag(buffer, "bold",      font = "bold $(fs)")
            create_tag(buffer, "italic",    font = "italic $fs")
            create_tag(buffer, "code",      font = "bold $fs", 
                foreground=mc.highlight_color, background=mc.highlight_background)

            insert_MD!(buffer, m)
#            tag(buffer, "normal", 1, length(buffer))
            
            n = new(view.handle, view, buffer)
            gobject_move_ref(n, view)
        end
        
        MarkdownTextView(m::String) = MarkdownTextView(Markdown.parse(m), "")
        MarkdownTextView(m::String, prelude::String, mc::MarkdownColors = MarkdownColors()) = MarkdownTextView(Markdown.parse(m), prelude, mc)
        MarkdownTextView(m::String, mc::MarkdownColors) = MarkdownTextView(Markdown.parse(m), "", mc)

    end
    
    function tag(buffer, what, i, j)
        apply_tag(buffer, what, 
            _GtkTextIter(buffer, i), _GtkTextIter(buffer, j) 
        )
    end

    function style_css(w::GtkWidget, css::String)
        sc = Gtk4.style_context(w)
        push!(sc, GtkCssProvider(css), 600)
    end

    function insert_MD!(buffer, m::Markdown.Header{N}, i) where N
        ip = i
       
        insert!(buffer, "    ")
        i += 4
        for el in m.text
            i = insert_MD!(buffer, el, i)
        end
        tag(buffer, "h$(min(N,4))", ip, i)
        i
    end

    function insert_MD!(buffer, m::Markdown.BlockQuote, i) 
        insert!(buffer, "│  ")
        i += 3
        for el in m.content
            i = insert_MD!(buffer, el, i)
        end
        i
    end

    function insert_MD!(buffer, m::String, i)
        insert!(buffer, m)
        i += length(m)
    end

    function insert_MD!(buffer, m::Markdown.LaTeX, i)
        i = insert_MD!(buffer, m.formula, i)
    end

    function insert_MD!(buffer, m::Markdown.Paragraph, i)
        for el in m.content
            i = insert_MD!(buffer, el, i)
        end
        i
    end

    function insert_MD!(buffer, m::Markdown.Code, i)
        insert!(buffer, m.code)
        tag(buffer, "code", i, i+sizeof(m.code)) 
        i += length(m.code)
    end

    function insert_MD!(buffer, m::Markdown.List, i)

        marker = k -> m.ordered == -1 ? "•" : "$(k)."
        for (k, it) in enumerate(m.items)
            insert!(buffer, "    $(marker(k)) ")
            i += 6 + (m.ordered == 1)
            for el in it
                i = insert_MD!(buffer, el, i)
            end
            insert!(buffer, "\n")
            i += 1
        end 
        i
    end

    tagname(m::Markdown.Italic) = "italic"
    tagname(m::Markdown.Bold) = "bold"
    
    function insert_MD!(buffer, m::T, i) where T <: Union{Markdown.Italic, Markdown.Bold}
        ip = i
        for el in m.text
            i = insert_MD!(buffer, el, i)
        end
        tag(buffer, tagname(m), ip, i) 
        i
    end
    
    function insert_MD!(buffer, m::Markdown.Link, i)
        for el in m.text
            i = insert_MD!(buffer, el, i)
        end
        insert!(buffer, "(")
        i += 1
        i = insert_MD!(buffer, m.url, i)
        insert!(buffer, ")")
        i += 1
    end

    function insert_MD!(buffer, m, i)
        if isdefined(m, :text) 
            for el in m.text
                i = insert_MD!(buffer, el, i)
            end
        end
        if isdefined(m, :content) 
            for el in m.content
                i = insert_MD!(buffer, el, i)
                insert!(buffer, "\n\n")
                i += 2
            end
        end
        i
    end

    function insert_MD!(buffer, m::Markdown.MD)
        i = length(buffer)+1
        for el in m.content
            i = insert_MD!(buffer, el, i)
            insert!(buffer, "\n\n")
            i += 2
        end
    end

    
end
    
