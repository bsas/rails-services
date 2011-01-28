module ActionController
  class Base

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
    def describe_resource(resource_name)
      @map = {}

      base = get_model(resource_name)
      if base
        base.columns.each do |column|
          @map[column.name] = {:type => column.type}
        end

        base.reflect_on_all_associations.each do |reflection|
          @map[reflection.name] = {:type => get_type(reflection.class_name)}
          @map[reflection.name][:collection] = true if reflection.collection?
        end
      else
        @map = {:error => true}
      end

      {resource_name => @map}
    end

    def describe_services
      list = []

      Rails.application.routes.routes.each do |route|
        requirements = route.requirements
        index        = requirements[:action] == 'index'
        @type        = get_type(requirements[:controller])

        map          = {
            :service => index ? requirements[:controller] : @type ?
                "#{requirements[:action]}_#{@type}" :
                "#{requirements[:action]}_#{requirements[:controller]}",
            :verb    => route.verb,
            :path    => route.path
        }
        map[:type] = @type if @type
        map[:collection] = true if index

        list << map unless route.verb.nil?
      end

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
end
