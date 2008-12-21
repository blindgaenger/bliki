# be careful not to harm the [[wikilinks]] plugin
# so the link need to start with BOL or a whitespace
class Page
  def plugin_auto_links content
    content.gsub(/(^|\s)(http\:\/\/\S+)/) do |m|
      "#{$1}<a href=\"#{$2}\">#{$2}</a>"
    end
  end
end
