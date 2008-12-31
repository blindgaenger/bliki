class Tag
  attr_accessor :id
  attr_accessor :page_count
  attr_accessor :score

  def initialize(params={})
    @id = params['id'] || params[:id]
    @page_count = params.include?('page_count') ? params['page_count'].to_i : 0
  end

  def self.all
    total_pages = 0
    hash = {}
    Page.all.collect { |page|
      page.tags.split(",").map { |t| t.strip }.uniq.each {|t|
        tag = hash[t]
        if tag.nil?
          tag = Tag.new(:id => t)
          hash[t] = tag
        end
        tag.page_count += 1
        total_pages += 1
      }
    }
    tags = hash.values

    tags.each {|tag|
      tag.score = tag.page_count.to_f / total_pages
    }

    tags.sort_by {|tag| tag.id}
  end

  def self.find_by_id(id)
    Tag.new(:id => id)
  end

end
