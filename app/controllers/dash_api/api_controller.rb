module DashApi
  class ApiController < ApplicationController         

    skip_before_action :verify_authenticity_token

    before_action :parse_query_params
    before_action :load_dash_table 

    def index                      
      resources = dash_scope
      authorize resources, :index? 
      @filters.each{|filter| resources = resources.where(filter) }            
      resources = resources.pg_search(@keywords) if @keywords.present?      
      resources = resources.order(@order) if @order.present?          
      resources = resources.select(@select) if @select.present?    
      
      if @stats.present?
        statistic, value = @stats.keys[0], @stats.values[0]&.to_sym
        resources = resources.send(statistic, value)
      else 
        resources = resources.page(@page).per(@per_page)
      end 

      render json: { 
        data: DashApi::Serializer.render(resources, includes: @includes),
        meta: {
          page: @page,
          per_page: @per_page,
          total_count: resources.respond_to?(:total_count) ? resources.total_count : 1
        }        
      }
    end 

    def show 
      resource = dash_scope.find(params[:id])
      authorize resource, :show? 
      render json: { 
        data: DashApi::Serializer.render(resource, includes: @includes) 
      }
    end 

    def create  
      resource = dash_scope.create!(dash_params)
      authorize resource, :create? 
      render json: { 
        data: DashApi::Serializer.render(resource) 
      }    
    end 

    def update 
      resource = dash_scope.find(params[:id])
      authorize resource, :update? 
      if resource.update(dash_params)
        render json: {           
          data: DashApi::Serializer.render(resource)
        }
      else 
        render json: { error: resource.errors.full_messages }, status: 422
      end 
    end 

    def destroy  
      resource = dash_scope.find(params[:id])
      authorize resource, :destroy? 
      resource.destroy 
      render json: { data: DashApi::Serializer.render(resource) }    
    end 

    def update_many 
      resources = dash_scope.where(id: params[:ids])
      authorize resources, :update? 
      resources.update(dash_params)
      render json: { data: DashApi::Serializer.render(resources) }
    end 

    def delete_many       
      resources = dash_scope.where(id: params[:ids])
      authorize resources, :destroy? 
      resources.destroy_all
      render json: { data: DashApi::Serializer.render(resources) }
    end 

    private

    def parse_query_params
      query = DashApi::Query.parse(params)
      @keywords = query[:keywords]
      @page =query[:page]
      @per_page = query[:per_page]
      @order = query[:order]
      @filters = query[:filters]
      @stats = query[:stats]
      @select = query[:select_fields]
      @includes = query[:associations]            
    end 

    def load_dash_table 
      @dash_table = DashTable.modelize(params[:table_name], includes: @includes)      
    end 

    def dash_scope 
      policy_scope(@dash_table)
    end 

    def dash_params
      params.require(params[:table_name]).permit!
    end 

  end 
end 