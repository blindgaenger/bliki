helpers do
  def link_to txt, url
    "<a href='#{url}'>#{txt}</a>"
  end
  def tag_list tags, where=""
    if tags.is_a? String
      tags = tags.split(",").collect { |t| t.strip }
    end
    return tags.map { |tag|
      tag = link_to tag, "#{where}/tag/#{tag}"
    }.join(", ")
  end
  def pingomatic
    begin
      return if Sinatra.options.ping == false
      require "erb"
      require "net/http"
      blog_name = ERB::Util.url_encode(Sinatra.options.name)
      url = ERB::Util.url_encode(Sinatra.options.base_url)
      feed_url = ERB::Util.url_encode(Sinatra.options.base_url + "/feed/")
      ping_url = "http://pingomatic.com/ping/?title=#{blog_name}&blogurl=#{url}&rssurl=#{feed_url}&chk_weblogscom=on&chk_blogs=on&chk_technorati=on&chk_feedburner=on&chk_syndic8=on&chk_newsgator=on&chk_myyahoo=on&chk_pubsubcom=on&chk_blogdigger=on&chk_blogrolling=on&chk_blogstreet=on&chk_moreover=on&chk_weblogalot=on&chk_icerocket=on&chk_newsisfree=on&chk_topicexchange=on&chk_google=on&chk_tailrank=on&chk_bloglines=on&chk_aiderss=on"
      Net::HTTP.get(URI.parse(ping_url))
    rescue Exception => e
      "oops"
    end
  end
  def reinvigorate
    return "<script type=\"text/javascript\" src=\"http://include.reinvigorate.net/re_.js\"></script>
    <script type=\"text/javascript\">
    re_(\"#{Sinatra.options.reinvigorate_code}\");
    </script>"
  end
  def atom_time date
    date.strftime("%Y-%m-%dT%H:%M:%SZ")
  end
  def disqus
    return "<div id=\"disqus_thread\"></div><script type=\"text/javascript\" src=\"http://disqus.com/forums/#{Sinatra.options.disqus_id}/embed.js\"></script><noscript><a href=\"http://#{Sinatra.options.disqus_id}.disqus.com/?url=ref\">View the discussion thread.</a></noscript><a href=\"http://disqus.com\" class=\"dsq-brlink\">blog comments powered by <span class=\"logo-disqus\">Disqus</span></a>"
  end
end
