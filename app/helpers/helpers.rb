def link_to(text, url, options={})
  url = "javascript: history.go(-1)" if url == :back
  options[:href] = url

  active_class = options.delete(:active_class)
  if active_class && @request
    if @request.path_info == url || (url != '/' && @request.path_info =~ /^#{url}/)
      options[:class] = "#{options[:class]} #{active_class}"
    end
  end

  attributes = options.map {|k, v| "#{k.to_s}=\"#{v}\"" }.join(' ')
  "<a #{attributes}>#{text}</a>"
end

def tag_links_for_page(page)
  page.tags.split(",").map { |tag| 
    link_to tag.strip, url_for_tags_show(tag.strip), :class => 'tag'
  }
end

#
# returns a readable representation of the specific DateTime
def relatize_date(date)
  require 'time'
  time = Time.parse(date.to_s)
  delta = (Time.now.to_i - time.to_i)
  if delta < 60 
    return 'less than a minute ago'
  elsif delta < 120
    return 'about a minute ago'
  elsif delta < (45*60)
    return "#{(delta/60).to_i} minutes ago"
  elsif delta < (120*60) 
    return 'about an hour ago'
  elsif delta < (24*60*60) 
    return "about #{(delta/3600).to_i} hours ago"
  elsif delta < (48*60*60)
    return '1 day ago'
  else
    days = (delta/86400).to_i
    if days < 4
      return "#{days} days ago"
    else
      return time.strftime("at %B %d, %Y")    
    end
  end
end

#
# an &lt;abbr&gt; element of the relatized date
def relatize_date_element(date)
  formatted = date.strftime("%Y-%m-%d %H:%M:%S")
  relatized = relatize_date(date)
  "<abbr title=\"#{formatted}\">#{relatized}</abbr>"
end


def pingomatic
  begin
    return if Sinatra.options.ping == false
    require "erb"
    require "net/http"
    blog_name = ERB::Util.url_encode(@app.title)
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
  return "<div id=\"disqus_thread\"></div><script type=\"text/javascript\" src=\"http://disqus.com/forums/#{Sinatra.options.disqus_id}/embed.js\"></script><noscript><a href=\"http://#{Sinatra.options.disqus_id}.disqus.com/?url=ref\">View the discussion thread.</a></noscript><a href=\"http://disqus.com\" class=\"dsq-brlink\">blog comments powered by <span class=\"logo-disqus\">Disqus</span></a>" unless @post.is_a? Page
end

def form_method model, verb=nil
  verb ||= model.already_exists? ? 'put' : 'post'
  "<input type=\"hidden\" name=\"_method\" value=\"#{verb.to_s}\" />"
end

