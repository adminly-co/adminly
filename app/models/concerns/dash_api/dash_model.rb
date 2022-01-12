module DashApi 
  module DashModel 
    extend ActiveSupport::Concern

    class_methods do       

      def modelize(table_name, includes: nil)         

        # Create an Abstract Active Record class and 
        # assign the table name from params 
        class_name = table_name.singularize.capitalize        
        if Object.const_defined? class_name
          klass = class_name.constantize          
        else 
          klass = Object.const_set class_name, Class.new(DashApi::DashTable)
        end 
        klass.table_name = table_name.downcase.pluralize

        # Define a default Pundit policy class for this model
        if Object.const_defined? "#{class_name}Policy"
          policy = "#{class_name}Policy".constantize          
        else 
          policy = Object.const_set "#{class_name}Policy", Class.new(ApplicationPolicy)
        end 

        # Clear the cache to to support live migrations
        klass.reset_column_information

        # We "guess" the model associations using Rails naming conventions
        klass.build_associations(includes) if includes.present?

        # Define the pg_search_scope for this model
        klass.build_pg_search_scope
        klass
      end 
      
      def build_associations(associations)
        return nil unless associations
        associations.each do |table_name|
          klass = DashTable.modelize(table_name)
          if is_singular?(table_name)
            self.belongs_to table_name.singularize.to_sym 
            klass.has_many self.table_name.pluralize.to_sym 
          else
            self.has_many table_name.pluralize.to_sym 
            klass.belongs_to self.table_name.singularize.to_sym 
          end 
        end
      end 

      def build_pg_search_scope
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

      def is_singular?(name)
        name && name.singularize == name 
      end 

      def searchable_fields
        return [] if self.table_name.nil?
        self.columns.map(&:name)
      end 

    end 
  end 
end 