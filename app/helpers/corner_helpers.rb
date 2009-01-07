def corner_steps(r)
  (1..r).map {|i| (r-Math::sqrt(r**2 - i**2)).round}
end

#
# <%= rounded_corners '<div>lala</div>', :radius => 20, :box_color => '#3465A4', :corner_color => '#fff', :style => "text-align: center; width: 100px;" %>
def rounded_corners(content, options={})
  radius = options.delete(:radius)
  box_background_color = options.delete(:box_color)
  line_border_color = options.delete(:corner_color)
  
  box_style = options.delete(:style)
  box_attributes = options.map {|k, v| "#{k.to_s}=\"#{v}\"" }.join(' ')

  steps = corner_steps(radius.to_i)

  html = []
  html << "<div style=\"position: relative; border: medium none; padding: #{radius}px; background: #{box_background_color}; #{box_style}\" #{box_attributes}>"
  html << "<div style=\"margin: -#{radius}px -#{radius}px 0px;\">"  
  steps.reverse.each do |i|
    html << "<div style=\"border-style: none solid; overflow: hidden; height: 1px; background-color: transparent; border-width: 0pt #{i}px; border-color: #{line_border_color};\"></div>"
  end
  html << "</div>"
  html << content
  html << "<div style=\"margin: 0pt; padding: 0pt; position: absolute; left: 0pt; bottom: 0pt; width: 100%;\">"
  steps.each do |i|
    html << "<div style=\"border-style: none solid; overflow: hidden; height: 1px; background-color: transparent; border-width: 0pt #{i}px; border-color: #{line_border_color};\"></div>"
  end
  html << "</div>"
  html << "</div>"

  html.join('')
end

