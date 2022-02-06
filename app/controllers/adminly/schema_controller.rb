module Adminly
  class SchemaController < ApplicationController 

    def index 
      tables = Adminly::Schema.table_names 
      render json: { data: tables }
    end 
    
    def schema       
      schema = Adminly::Schema.db_schema
      render json: { data: schema }
    end 

    def show         
      table_schema = Adminly::Schema.table_schema(params[:table_name])
      render json: { data: table_schema }
    end 

  end 
end 