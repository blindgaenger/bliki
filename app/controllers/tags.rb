rest Tag, :renderer => :erb, :editable => false do
  def show
    super
    @pages = Page.all(:tags.includes => @tag.id, :order => {:title => :asc})
  end
end
