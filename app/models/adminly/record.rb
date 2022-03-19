require 'csv'

module Adminly
  class Record < ApplicationRecord
    include PgSearch::Model

    self.abstract_class = true

    def self.to_active_record(table_name, belongs_to: nil, has_many: nil, habtm: nil)

      # Create an Abstract Active Record class and
      # assign the table name from params
      class_name = table_name.singularize.capitalize

      if Object.const_defined? class_name
        klass = class_name.constantize
      else         
        klass = Object.const_set class_name, Class.new(Adminly::Record)
      end 
      
      klass.table_name = table_name.downcase
      # Clear the cache to to support live migrations
      klass.reset_column_information
      
      # Define a default Pundit policy class for this model
      if Object.const_defined? "#{class_name}Policy"
        policy = "#{class_name}Policy".constantize
      else
        policy = Object.const_set "#{class_name}Policy", Class.new(ApplicationPolicy)
      end      

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
        name, table_name, foreign_key = table.split(":")
        foreign_key = table_name.singularize.downcase + '_id' if foreign_key.nil?
        klass = Adminly::Record.to_active_record(table_name)
        self.belongs_to name.to_sym, class_name: klass.name, foreign_key: foreign_key, optional: true
      end

      has_many&.each do |table|
        name, table_name, foreign_key = table.split(":")
        foreign_key = self.table_name.singularize.downcase + '_id' if foreign_key.nil?
        klass = Adminly::Record.to_active_record(table_name)
        self.has_many name.to_sym, class_name: klass.name, foreign_key: foreign_key
      end

      habtm&.each do |table|
        name, table_name, join_table = table.split(":")
        klass = Adminly::Record.to_active_record(table_name)
        self.has_and_belongs_to_many name.to_sym, class_name: klass.name, join_table: join_table
      end

    end

    def self.build_pg_search_scope
      self.pg_search_scope(
        :pg_search,
        against: self.table_columns,
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

    def self.table_columns
      return [] if self.table_name.nil?
      self.columns.map(&:name)
    end

    def self.to_csv
      header_written = false
      CSV.generate(headers: true) do |csv|
        current_scope.find_each do |record|
          unless header_written
            csv << record.attributes.keys
            header_written = true
          end

          csv << record.attributes.values
        end
      end
    end
  end
end
