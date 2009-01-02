def disqus_head
  if @app.use_comments
    <<-XXX
<script type="text/javascript">
//<![CDATA[
  var disqus_developer = #{production? ? 0 : 1};
  var disqus_iframe_css = "#{@app.base_url}/css/disqus.css"
//]]>
</script>
    XXX
  end
end

def disqus_comments
  if @app.use_comments
    <<-XXX
<div id="disqus_thread"></div><script type="text/javascript" src="http://disqus.com/forums/#{@app.disqus_id}/embed.js"></script><noscript><a href="http://#{@app.disqus_id}.disqus.com/?url=ref">View the discussion thread.</a></noscript>
    XXX
  end
end


def disqus_scripts
  if @app.use_comments 
    <<-XXX
<script type="text/javascript">
//<![CDATA[
(function() {
    var links = document.getElementsByTagName('a');
    var query = '?';
    for(var i = 0; i < links.length; i++) {
	    if(links[i].href.indexOf('#disqus_thread') >= 0) {
		    query += 'url' + i + '=' + encodeURIComponent(links[i].href) + '&';
	    }
    }
    document.write('<script type="text/javascript" src="http://disqus.com/forums/#{@app.disqus_id}/get_num_replies.js' + query + '"></' + 'script>');
  })();
//]]>
</script>
    XXX
  end
end

def disqus_link(page, text)
  if @app.use_comments
    <<-XXX
<div>#{link_to text, url_for_pages_comments(page)}</div>
    XXX
  end
end

def url_for_pages_comments(page)
  "#{url_for_pages_show(page)}#disqus_thread"
end
