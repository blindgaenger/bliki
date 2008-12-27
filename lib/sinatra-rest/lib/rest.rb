require 'rubygems'
require 'english/inflect'

module Sinatra
  module REST

    #
    # adds restful routes and url helpers for the model  
    def rest(model_class, options={}, &block)
      model, singular, plural = conjugate(model_class)

      renderer = options.delete(:renderer)
      renderer ||= :haml

      # add some url_for_* helpers
      Sinatra::EventContext.class_eval <<-XXX
        # index GET /models
        def url_for_#{plural}_index
          '/#{plural}'
        end
        
        # new GET /models/new
        def url_for_#{plural}_new
          '/#{plural}/new'
        end
        
        # create POST /models
        def url_for_#{plural}_create
          '/#{plural}'
        end
        
        # show GET /models/1
        def url_for_#{plural}_show(model)
          "/#{plural}/\#{model.id}"
        end
        
        # edit GET /models/1/edit
        def url_for_#{plural}_edit(model)
          "/#{plural}/\#{model.id}/edit"
        end

        # update PUT /models/1
        def url_for_#{plural}_update(model)
          "/#{plural}/\#{model.id}"
        end

        # destroy DELETE /models/1
        def url_for_#{plural}_destroy(model)
          "/#{plural}/\#{model.id}"
        end
      XXX

      # create an own module and fill it with the template
      controller_template = Module.new
      controller_template.class_eval <<-XXX
        # index GET /models
        def index
          @#{plural} = #{model}.all
        end

        # new GET /models/new
        def new
          @#{singular} = #{model}.new
        end

        # create POST /models
        def create
          @#{singular} = #{model}.new(params)
        end

        # show GET /models/1
        def show
          @#{singular} = #{model}[params[:id]]
        end

        # edit GET /models/1/edit
        def edit
          @#{singular} = #{model}[params[:id]]
        end

        # update PUT /models/1
        def update
          @#{singular} = #{model}[params[:id]]
          @#{singular}.update_attributes(params)
        end

        # destroy DELETE /models/1
        def destroy
          @#{singular} = #{model}[params[:id]]
          #{model}.delete(@#{singular}.id)
        end
      XXX
      
      # create an own module, to override the template with custom methods
      # this way, you can still use #super# in the overridden methods
      if block_given?
        controller_custom = Module.new &block
      end

      # create the restful routes
      self.instance_eval <<-XXX
        # add the correct modules to the EventContext
        # use a metaclass so it isn't included again next time
        before do
          # TODO: which one? REQUEST_PATH, PATH_INFO, REQUEST_URI
          if self.request.env['REQUEST_PATH'] =~ /^\\/#{plural}\\b/
            metaclass = class << self; self; end
            metaclass.send(:include, controller_template)
            metaclass.send(:include, controller_custom) if controller_custom
          end
        end

        # index GET /models
        get '/#{plural}' do
          index
          #{renderer.to_s} :#{plural}_index, options
        end

        # new GET /models/new
        get '/#{plural}/new' do
          new
          #{renderer.to_s} :#{plural}_new, options
        end

        # create POST /models
        post '/#{plural}' do
          create
          redirect url_for_#{plural}_show(@#{singular})
        end

        # show GET /models/1
        get '/#{plural}/:id' do
          show
          #{renderer.to_s} :#{plural}_show, options
        end

        # edit GET /models/1/edit
        get '/#{plural}/:id/edit' do
          edit
          #{renderer.to_s} :#{plural}_edit, options
        end

        # update PUT /models/1
        put '/#{plural}/:id' do
          update
          redirect url_for_#{plural}_show(@#{singular})
        end

        # destroy DELETE /models/1
        delete '/#{plural}/:id' do
          destroy
          redirect url_for_#{plural}_index
        end      
      XXX

    end

  protected
    #
    # creates the necessary forms of the model name
    def conjugate(model_class)
      model = model_class.to_s.match(/(\w+)$/)[0]
      singular = model.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
      return model, singular, singular.pluralize
    end

  end # REST
end # Sinatra

include Sinatra::REST

