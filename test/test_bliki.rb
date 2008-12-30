$LOAD_PATH.unshift "../lib"

require 'rubygems'
require 'lib/sinatra/lib/sinatra'
require 'lib/sinatra/lib/sinatra/test/unit'
require 'bliki'
require 'feed_validator'
require 'fileutils'
require 'feed_validator/assertions'
require 'redgreen'

class Test::Unit::TestCase
  def self.test(name, &block)
    test_name = "test_#{name.gsub(/\s+/,'_')}".downcase.to_sym
    defined = instance_method(test_name) rescue false
    raise "#{test_name} is already defined in #{self}" if defined
    if block_given?
      define_method(test_name, &block)
    else
      define_method(test_name) do
        flunk "No implementation provided for '#{name}'"
      end
    end
  end
end

class BlikiTest < Test::Unit::TestCase
  def setup
    # reset cache
    Dir["public/**/*"].each do |file|
      FileUtils.rm file
    end
    FileUtils.mkdir_p "test/public"
    Dir["test/public/**/*"].each do |file|
      FileUtils.rm file
    end
    # clear mock content
    Dir["db/test/datastore/**/*"].each do |file|
      FileUtils.rm file unless File.directory? file
    end
    Stone.start(Dir.pwd + "/db/#{Sinatra.env.to_s}", Dir.glob(File.join(Dir.pwd,"models/*")))
    # create one page
    p = Page.new(:title => "First page", :body => "This is a sample page", :tags => "test")
    p.save
  end
  def teardown
    # clear mock content
    Dir["db/test/datastore/**/*"].each do |file|
      FileUtils.rm file unless File.directory? file
    end
  end

  # Test application runs at all
  test "Sinatra is loaded" do
    assert_instance_of Module, Sinatra
  end
  test "Views folder is correctly setup" do
    assert_equal "themes/#{Sinatra.options.theme}", Sinatra.options.views
  end
  test "Application is running" do
    get_it "/"
    assert_equal 200, status
  end

  # Content
  test "Title is Ok" do
    get_it "/"
    assert body.scan(/#{@app.title}/).size > 0
  end

  # Mock content
  # Make sure authorization is disabled
  test "Auth is disabled in testing environment" do
    assert_equal false, Sinatra.application.options.use_auth
  end
  # Mock content: Pages
  test "Page creation works under the hood" do
    first_page = Page.new(:title => "First page", :body => "Wadus wadus", :tags => "foo, bar")
    first_page.save
    get_it "/page/first-page"
    assert_equal 200, status
    get_it "/tag/foo"
    assert_equal 200, status
    get_it "/tag/bar"
    assert_equal 200, status
  end
  test "Page creation works over the hood" do
    post_it "/new", :title => "Second page", :body => "Wadus wadus", :tags => "wadus, badus"
    get_it "/page/second-page"
    assert_equal 200, status
    get_it "/tag/wadus"
    assert_equal 200, status
    get_it "/tag/badus"
    assert_equal 200, status
  end
  # Mock content: Pages
  test "Page creation works under the hood" do
    first_page = Page.new(:title => "First page", :body => "Wadus wadus", :tags => "foo, bar")
    first_page.save
    get_it "/first-page"
    assert_equal 200, status
    get_it "/tag/foo"
    assert_equal 200, status
    get_it "/tag/bar"
    assert_equal 200, status
  end
  test "Page creation works over the hood" do
    post_it "/2/new", :title => "Second page", :body => "Wadus wadus", :tags => "wadus, badus"
    get_it "/second-page"
    assert_equal 200, status
    get_it "/tag/wadus"
    assert_equal 200, status
    get_it "/tag/badus"
    assert_equal 200, status
  end

  # Stone
  test "Stone works as expected" do
    all_pages_start = Page.all.size
    first_page = Page[1]
    assert_equal 1, first_page.id
    new_page = Page.new(:title => "Third page", :body => "Third page", :tags => "third")
    new_page.save
    all_pages_end = Page.all.size
    assert_equal all_pages_end, all_pages_start + 1
  end
  test "Stone works with more than 99 existing pages" do
    page_count = Page.all.size
    (1..200-page_count).each do |i|
      tmp_page = Page.new(:title => "Page #{i}", :body => "Body #{i}", :tags => "tag#{i}" )
      tmp_page.save
    end
    all_pages = Page.all
    assert_equal(200, all_pages.size)
    assert_equal(200, all_pages.last.id)
    assert_equal(Page[200], all_pages.last)
    (1..100).each do |i|
      tmp_page = Page.new(:title => "Page #{i}", :body => "Body #{i}", :tags => "tag#{i}" )
      tmp_page.save
    end
    all_pages = Page.all
    assert_equal(300, all_pages.size)
    assert_equal(Page[300], all_pages.last)
  end
  test "Pages have a creation date" do
    first_page = Page[1]
    assert_not_nil first_page.created_at
  end
  test "Pages have an update date" do
    first_page = Page[1]
    assert_not_nil first_page.updated_at
    assert_kind_of DateTime, first_page.updated_at
  end
  test "Pages updated_at field is updated on save" do
    first_page = Page[1]
    original_updated_at = first_page.updated_at
    first_page.tags = "foo, bar, baz"
    first_page.save
    assert_not_equal original_updated_at, first_page.updated_at
    assert_kind_of DateTime, first_page.updated_at
  end
  test "Pages updated_at field is updated on put" do
    first_page = Page[1]
    original_updated_at = first_page.updated_at
    first_page.update_attributes(
      :tags => "foo, bar, baz"
    )
    assert_not_equal original_updated_at, first_page.updated_at
    assert_kind_of DateTime, first_page.updated_at
  end

  # Tags
  test "Tag page works" do
    get_it "/tag/tag1"
    assert_equal 200, status
  end

  # Content
  test "wikilinks are converted to links" do
    new_page = Page.new(:title => "test_page", :body => "[[wikilink1]] [[wikilink2]]", :tags => "wiki")
    new_page.save
    get_it "/test_page"
    assert body.scan("<a href=\"#{Sinatra.options.base_url}/wikilink1\">wikilink1</a>").size > 0
    assert body.scan("<a href=\"#{Sinatra.options.base_url}/wikilink2\">wikilink2</a>").size > 0
  end
  test "WikiWords are converted to links" do
    new_page = Page.new(:title => "test_wikiwords", :body => "WikiWord WikiWikiWord", :tags => "wiki")
    new_page.save
    get_it "/test_wikiwords"
    assert body.scan("<a href=\"#{Sinatra.options.base_url}/wikiword\">WikiWord</a>").size > 0
    assert body.scan("<a href=\"#{Sinatra.options.base_url}/wikiwikiword\">WikiWikiWord</a>").size > 0
  end

  # CSS: Base CSS
  test "CSS works" do
    get_it "/base.css"
    assert_equal 200, status
  end

  # Attachments
  test "attachment relationships work at model level" do
    page_with_attach = Page.new(:title => "Page with attach", :body => "this page has an attach", :tags => "attach")
    page_with_attach.save
    a = Attachment.new(:name => "foo", :path => Sinatra.options.public, :content => File.open("README.markdown"), :page_id => page_with_attach.id)
    a.save
    b = Attachment.new(:name => "bar", :path => Sinatra.options.public, :content => File.open("README.markdown"), :page_id => page_with_attach.id)
    b.save
    assert_equal 2, page_with_attach.attachment.size
  end
  test "Attachments are created with unique names" do
    a = Attachment.new(:name => "test_one", :path => Sinatra.options.public, :content => File.open("README.markdown"))
    a.save
    b = Attachment.new(:name => "test_one", :path => Sinatra.options.public, :content => File.open("README.markdown"))
    assert b.save == false
  end
  test "Files are created when saving attachments" do
    a = Attachment.new(:name => "attach", :path => Sinatra.options.public, :content => File.open("README.markdown"))
    assert a.save == true, "File already exists"
    assert File.exist?(Sinatra.options.public / a.name ), "File not created"
  end
  test "Content for attachments is saved correctly" do
    a = Attachment.new(:name => "attach_content", :path => Sinatra.options.public, :content => File.open("README.markdown"))
    a.save
    assert File.open(a.path / a.name,"r").read.scan("bliki").size > 1
  end

  # Feed
  test "Feed is valid" do
    get_it "/feed/"
    assert_equal 200, status
    assert_valid_feed body
  end
end
