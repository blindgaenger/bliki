module BlikiContent
  def plugin_wikilinks content
    content.gsub(/\[\[(\w+(?:\s+\w+)*)\]\]/ui) do |m|
      "<a href=\"#{Sinatra.options.base_url}/#{$1.slugalize}\">#{$1}</a>"
    end
  end
end
