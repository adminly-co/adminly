module Adminly 
  class Record < ApplicationRecord   
    include PgSearch::Model 
    
    self.abstract_class = true    

    def self.to_active_record(table_name, belongs_to: nil, has_many: nil, habtm: nil)

      # Create an Abstract Active Record class and
      # assign the table name from params
      class_name = table_name.singularize.capitalize
                  
      Object.send(:remove_const, class_name) if Object.const_defined? class_name                   
      klass = Object.const_set class_name, Class.new(Adminly::Record)
      
      #klass.table_name = table_name.downcase.pluralize
      klass.table_name = table_name.downcase

      # Define a default Pundit policy class for this model
      if Object.const_defined? "#{class_name}Policy"
        policy = "#{class_name}Policy".constantize
      else
        policy = Object.const_set "#{class_name}Policy", Class.new(ApplicationPolicy)
      end

      # Clear the cache to to support live migrations
      klass.reset_column_information

      # Build the model associations from the params
      klass.build_associations(          
        belongs_to: belongs_to,
        has_many: has_many,
        habtm: habtm
      )

      # Define the pg_search_scope for this model
      if Adminly::Schema.db_type == 'postgresql'
        klass.build_pg_search_scope
      end

      klass
    end

    def self.build_associations(belongs_to: nil, has_many: nil,  habtm: nil)        
      
      belongs_to&.each do |table|         
        table_name, foreign_key = table.split(":")        
        foreign_key = table_name.singularize.downcase + '_id' if foreign_key.nil?          
        klass = Adminly::Record.to_active_record(table_name)
        self.belongs_to table_name.singularize.downcase.to_sym, class_name: klass.name, foreign_key: foreign_key        
      end 

      has_many&.each do |table|         
        table_name, foreign_key = table.split(":")    
        foreign_key = self.table_name.singularize.downcase + '_id' if foreign_key.nil?       
        klass = Adminly::Record.to_active_record(table_name)         
        self.has_many table_name.downcase.to_sym, class_name: klass.name, foreign_key: foreign_key
      end 

      habtm&.each do |table|         
        table_name, join_table = table.split(":")                        
        klass = Adminly::Record.to_active_record(table_name)         
        self.has_and_belongs_to_many table_name.downcase.to_sym, class_name: klass.name, join_table: join_table
      end 

    end

    def self.build_pg_search_scope
      self.pg_search_scope(
        :pg_search,
        against: self.searchable_fields,
        using: {
          tsearch: {
            prefix: true,
            dictionary: "english"
          }
        }
      )
    end

    def self.is_singular?(name)
      name && name.singularize == name
    end

    def self.searchable_fields
      return [] if self.table_name.nil?
      self.columns.map(&:name)
    end

  end 
end