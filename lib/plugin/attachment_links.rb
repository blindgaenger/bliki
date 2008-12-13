# ![lala](/attachments/logo.png)
# <file:logo.png>
# {{logo.png}}
# file://logo.png
class Post
  def plugin_attachment_link content
    return content if attachments.nil? or attachments.empty?

    content = attachments.inject(content) do |result, attachment|
      filename = Regexp.escape(attachment.name)
      puts filename
      result.gsub(/(\{\{#{filename}\}\})/) do |m|
        "<a href=\"#{attachment.link}\">#{attachment.name}</a>"
      end
    end
  
    content.gsub(/<file:([^>]+?)>/) do |m|
      filename = $1
      if %w(.png .jpg .jpeg .gif).include? File.extname(filename)
        "<img src=\"/attachments/#{filename}\">"
      else
        "<a href=\"/attachments/#{filename}\">#{filename}</a>"
      end
    end
  end
end
