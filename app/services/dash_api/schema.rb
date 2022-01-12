module DashApi
  module Schema 

    EXCLUDED_TABLES = [
      'ar_internal_metadata', 
      'schema_migrations'
    ]

    attr_accessor :tables 

    def self.table_names
      @tables = ActiveRecord::Base.connection.tables
      @tables.filter!{|t| !EXCLUDED_TABLES.include?(t)}.sort!
    end 

    def self.table_schema(table_name) 
      @tables = table_names 
      dash_table = DashTable.modelize(table_name)
      dash_table.reset_column_information      
      dash_table.columns.map{ |column| 
        render_column(column)
      } 
    end 

    def self.db_schema 
      @tables = table_names
      schema = {
        tables: @tables
      }
      @tables.each do |table_name|
        schema[table_name] = table_schema(table_name)
      end      
      schema   
    end 

    def self.render_column(column)      
      {
        friendly_name: column.human_name,
        name: column.name,
        type: column.type,
        array: column.array,
        default: column.default,
        limit: column.sql_type_metadata.limit,
        precision: column.sql_type_metadata.precision,
        foreign_key: foreign_key?(column.name),
        foreign_table: foreign_table(column.name) 
      }
    end 

    def self.foreign_key?(column_name)      
      column_name[-2..-1]&.downcase === 'id' && column_name.downcase != 'id'
    end 

    def self.foreign_table(column_name)
      table_prefix = column_name[0...-3]      
      @tables.find{|t| t === table_prefix || t === table_prefix.pluralize }
    end 
    
  end 
end 
