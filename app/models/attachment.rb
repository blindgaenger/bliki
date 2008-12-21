class Attachment
  include Stone::Resource

  field :name, String, :unique => true
  field :path, String
  field :link, String
  field :content, File
  belongs_to :post

  validates_presence_of :name  

  before_save :save_file

  def save_file
    return false if File.exist?(self.path + "/" + self.name)
    File.open(self.path + "/" + self.name,"w") do |f|
      f << self.content.read
    end
  end
end
