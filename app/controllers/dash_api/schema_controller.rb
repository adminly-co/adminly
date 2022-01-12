module DashApi
  class SchemaController < ApplicationController 

    def index 
      tables = DashApi::Schema.table_names 
      render json: { data: tables }
    end 
    
    def schema       
      schema = DashApi::Schema.db_schema
      render json: { data: schema }
    end 

    def show         
      table_schema = DashApi::Schema.table_schema(params[:table_name])
      render json: { data: table_schema }
    end 

  end 
end 