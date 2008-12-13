require "lib/slugalizer"

module BlikiContent
  def update_slug
    self.nicetitle = self.title.slugalize
  end
  def date
    self.created_at.strftime("%d %b %Y")
  end
  def day
    self.created_at.strftime("%d")
  end
  def month
    self.created_at.strftime("%m")
  end
  def year
    self.created_at.strftime("%Y")
  end
  def content
    @content_plugins = body
    self.methods.grep(/^plugin_/) do |m|
      result = self.send(m, @content_plugins) 
      unless result.nil?
        raise "plugin #{m} didn't return a String: #{result.to_s}" unless result.is_a? String
        @content_plugins = result
      end
    end
    html = RDiscount.new(@content_plugins).to_html
    return html
  end
  def link
    "/#{self.year}/#{self.month}/#{self.day}/#{self.nicetitle}/"
  end
  def edit_link
    "/#{self.class.to_s.downcase}/#{self.id.to_s}/edit"
  end
end
