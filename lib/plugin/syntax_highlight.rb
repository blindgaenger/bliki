module BlikiContent
  begin
    require 'uv'
    @@uv_gem = true
  rescue LoadError
    @@uv_gem = false  
  end

  def plugin_syntax_highlight content
    regex = /\{\{(.*?)\n(.*?)\}\}/m
    content.gsub(regex) do |m|
      syntax = $1.strip
      code = $2
      
      line_count = code.count("\n")
      line_numbers = (1..line_count).to_a.join("\n")

      if @@uv_gem
        syntax = $1 if syntax.empty? and code =~ /^#\!(\w+)\n/
        syntax = 'plain_text' if syntax.empty?
        formatted_code = Uv.parse(code, 'xhtml', syntax, false, 'sunburst', false)
      else
        formatted_code = "<pre class=\"sunburst\">#{code}</pre>"
      end
      
      "<div class=\"code\"><pre class=\"lines\">#{line_numbers}</pre>#{formatted_code}</div>"
    end
  end
end


