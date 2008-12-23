require 'rubygems'
require 'english/inflect' # necessary for the pluralize methods

module Sinatra
  module REST
  
    #
    # include Sinatra::REST
    # rest YourModelClass
    class << self
      def included(base)
        base.class_eval <<-XXX
          def rest(model_class, options={}, &block)
            url_for_model self, model_class, options
            block.call if block_given?
            routes_for_model self, model_class, options
          end
        XXX
      end
    end
  
  protected
    #
    # creates the necessary forms of the model name
    def conjugate(model_class)
      model = model_class.to_s.match(/(\w+)$/)[0]
      singular = model.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
      return model, singular, singular.pluralize
    end
    
    #
    # adds the restful routes for the model
    def routes_for_model(base, model_class, options)
      model, singular, plural = conjugate(model_class)
      renderer = options[:renderer] || :haml
      #Sinatra.application.instance_eval
      base.instance_eval <<-XXX
        # index GET /models
        get '/#{plural}' do
          @#{plural} = #{model}.all
          erb(:#{plural}_index)
        end

        # new GET /models/new
        get '/#{plural}/new' do
          @#{singular} = #{model}.new
          erb(:#{plural}_new)
        end

        # create POST /models
        post '/#{plural}' do
          @#{singular} = #{model}.new(params)
          redirect "/#{plural}/\#{@#{singular}.id}"  
        end

        # show GET /models/1
        get '/#{plural}/:id' do
          @#{singular} = #{model}[params[:id]]
          erb(:#{plural}_show)
        end

        # edit GET /models/1/edit
        get '/#{plural}/:id/edit' do
          @#{singular} = #{model}[params[:id]]
          erb(:#{plural}_edit)
        end

        # update PUT /models/1
        put '/#{plural}/:id' do
          @#{singular} = #{model}[params[:id]]
          @#{singular}.update_attributes(params)
          redirect "/#{plural}/\#{@#{singular}.id}"  
        end

        # destroy DELETE /models/1
        delete '/#{plural}/:id' do
          @#{singular} = #{model}[params[:id]]
          #{model}.delete(@#{singular}.id)
          redirect "/#{plural}"
        end
      XXX
    end
  
    #
    # adds url helpers to sinatra's helper context
    # this is the same as #helpers do .... end#
    def url_for_model(base, model_class, options)
      model, singular, plural = conjugate(model_class)
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
    end

  end
end

include Sinatra::REST

