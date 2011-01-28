class RailsServicesController < ActionController::Base

  # Rails 3 routes
  # match '/info(.:format)' => 'rails_services#info_services'
  # match '/info/:resource(.:format)' => 'rails_services#info_resource'

  # Rails 2 routes
  # map.connect 'info.:format', :controller => "rails_services", :action => "info_services"
  # map.connect 'info/:resource.:format', :controller => "rails_services", :action => "info_resource"

  def info_resource
    respond_to do |format|
      #format.xml  { render :xml => xml??? }
      format.json { render :json => describe_resource(params[:resource]) }
    end
  end

  def info_services
    respond_to do |format|
      #format.xml  { render :xml => xml??? }
      format.json { render :json => describe_services }
    end
  end

  private
  SINGLE_ENUM = [:belongs_to, :has_one].to_enum
  IS_RAILS_3  = Rails::VERSION::MAJOR > 2

  def describe_resource(resource_name)
    map  = {}

    base = get_model(resource_name)
    if base
      base.columns.each do |column|
        map[column.name] = {:type => column.type}
      end

      base.reflect_on_all_associations.each do |reflection|
        map[reflection.name] = {:type => get_type(reflection.class_name)}
        map[reflection.name][:collection] = true unless SINGLE_ENUM.include? reflection.macro
        map.delete(reflection.association_foreign_key)
      end
    else
      map = {:error => true}
    end

    # returns the resource graph
    {resource_name => map}
  end

  def describe_services
    list   = []

    routes = IS_RAILS_3 ? Rails.application.routes.routes.each : ActionController::Routing::Routes.routes
    routes.each do |route|
      verb         = ((IS_RAILS_3 ? route.verb : route.conditions[:method]) || :any).to_s.upcase
      path         = IS_RAILS_3 ? route.path : route.segments.to_s.gsub(/\?$/, '')

      requirements = route.requirements
      index        = requirements[:action] == 'index'
      @type        = get_type(requirements[:controller])

      map          = {
          :name => index ? requirements[:controller] : @type ?
              "#{requirements[:action]}_#{@type}" :
              "#{requirements[:action]}_#{requirements[:controller]}",
          :verb => verb,
          :path => path
      }
      map[:type] = @type if @type
      map[:collection] = true if index

      list << map unless verb.nil? or verb == 'ANY'
    end

    # returns the services graph
    list
  end

  def get_model(model_name)
    ActiveRecord.const_get(model_name.classify)
  rescue
    nil
  end

  def get_type(model_name)
    get_model(model_name).model_name.element
  rescue
    nil
  end

end