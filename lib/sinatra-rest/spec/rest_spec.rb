require File.join('lib', 'rest')
require '../sinatra/lib/sinatra'
require 'spec'
require 'facets'

class Resource
  attr_accessor :id
  
  def initialize(id=nil)
    @id = id
  end
  
  def self.all
    return Resource.new(1), Resource.new(2), Resource.new(3)
  end
  
end

class MyResource
end

module MyModule
  class ModuleResource
  end
end

describe Sinatra::REST do

  describe 'as code generator' do
    it "should conjugate a simple model name" do
      Sinatra::REST.conjugate(Resource).should eql(%w(Resource resource resources))
    end

    it "should conjugate a complex model name" do
      Sinatra::REST.conjugate(MyResource).should eql(%w(MyResource my_resource my_resources))
    end

    it "should conjugate a model name inside a module" do
      Sinatra::REST.conjugate(MyModule::ModuleResource).should eql(%w(ModuleResource module_resource module_resources))
    end
  end


  describe 'as route generator' do
  
    before(:each) do
      Sinatra.application.events.clear
    end
  
    it 'should add restful routes for a model' do
      rest Resource
      events = Sinatra.application.events

      events[:get].size.should be(4)      
      events[:get][0].path.should == '/resources'
      events[:get][1].path.should == '/resources/new'
      events[:get][2].path.should == '/resources/:id'
      events[:get][3].path.should == '/resources/:id/edit'
      
      events[:post].size.should be(1)
      events[:post][0].path.should == '/resources'
      
      events[:put].size.should be(1)
      events[:put][0].path.should == '/resources/:id'

      events[:delete].size.should be(1)      
      events[:delete][0].path.should == '/resources/:id'
    end
    
    it 'should list all models' do
    
#      resource_mock = mock Resource
#      resource_mock.should_receive(:all).and_return([])
#      resource_mock.should_receive(:coffee).exactly(3).times.and_return(:americano)

    
      rest Resource
      events = Sinatra.application.events

      #result = events[:get].find {|e| e.path == '/resources'}
      #p result.block.call

    end
    
  end


  describe 'as url generator' do
  
    it 'should add url_for helper methods' do
      rest Resource
      
      methods = Sinatra::EventContext.instance_methods.grep /^url_for_resources_/
      methods.size.should == 7

      response_mock = mock "Response"
      response_mock.should_receive(:"body=").with(nil).and_return(nil)
      context = Sinatra::EventContext.new(nil, response_mock, nil)

      @resource = Resource.new
      @resource.id = 99
      
      context.url_for_resources_index.should == '/resources'
      context.url_for_resources_new.should == '/resources/new'
      context.url_for_resources_create.should == '/resources'
      context.url_for_resources_show(@resource).should == '/resources/99'
      context.url_for_resources_edit(@resource).should == '/resources/99/edit'
      context.url_for_resources_update(@resource).should == '/resources/99'
      context.url_for_resources_destroy(@resource).should == '/resources/99'
    end
      
  end
  
end

