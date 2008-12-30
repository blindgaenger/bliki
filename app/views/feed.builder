base_url = Sinatra.options.base_url
feed_url = base_url + "/feed/"
title = @app.title + " - " + @app.subtitle
limit = Sinatra.options.limit
author_name = Sinatra.options.author_name
author_uri = base_url
# Build feed
xml.instruct! :xml, :version => "1.0"
xml.feed(:xmlns => 'http://www.w3.org/2005/Atom') do
  # Add primary attributes
  xml.id      base_url + '/'
  xml.title   title
  # Add date
  xml.updated atom_time(@pages.first.updated_at)
  # Add links
  xml.link(:rel => 'alternate', :href => base_url)
  xml.link(:rel => 'self',      :href => feed_url)
  # Add author information
  xml.author do
    xml.name  author_name
    xml.uri   author_uri
  end
  # Add pages
  @pages.each do |page|
    xml.entry do
      page_path = base_url + page.link
      page_id = "tag:" + base_url.gsub("http://","") + "," + page.created_at.strftime("%Y-%m-%d") + ":" + atom_time(page.created_at)
      # Add primary attributes
      xml.id         page_id
      xml.title      page.title, :type => 'html'
      # Add dates
      xml.published  atom_time(page.created_at)
      xml.updated    atom_time(page.updated_at)
      # Add link
      xml.link(:rel => 'alternate', :href => page_path)
      # Add content
      xml.content    page.content, :type => 'html'
      xml.summary    page.content[0..100], :type => 'html' unless page.content.nil?
    end
  end
end
