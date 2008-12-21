class Page
  begin
    require 'uv'
    @@syntaxes = Uv.syntaxes.inject({}) {|m, s| m[s] = s; m}
    @@syntaxes['shell'] = 'shell-unix-generic'
    @@syntaxes['sh'] = 'shell-unix-generic'
  rescue LoadError
    @@syntaxes = nil
  end

  def plugin_syntax_highlight content
    regex = /\{\{([^\n]*?)\n(.+?)\}\}/m
    content.gsub(regex) do |m|
      syntax = $1.strip
      code = $2
      
      line_count = code.count("\n")
      line_numbers = (1..line_count).to_a.join("\n")

      unless @@syntaxes.nil?
        syntax = $1 if syntax.empty? and code =~ /^#\!(\w+)\n/
        syntax = @@syntaxes[syntax]
        syntax ||= 'plain_text'
        formatted_code = Uv.parse(code, 'xhtml', syntax, false, 'sunburst', false)
      else
        formatted_code = "<pre class=\"sunburst\">#{code}</pre>"
      end
      
      "<div class=\"code\"><pre class=\"lines\">#{line_numbers}</pre>#{formatted_code}</div>"
    end
  end
end


