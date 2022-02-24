module Adminly 
  module Scope   
    extend ActiveSupport::Concern

    included do
      
      before_action :parse_query_params 

      def adminly_scope(resources) 
        @adminly_query.filters.each do |filter| 
          resources = resources.where(filter) 
        end 
        resources = resources.pg_search(@adminly_query.keywords) if @adminly_query.keywords?
        resources = resources.order(@adminly_query.order) if @adminly_query.order?
        resources = resources.select(@adminly_query.select) if @adminly_query.select?  
        resources = resources.page(@adminly_query.page).per(@adminly_query.per_page)              
        resources
      end 

      def adminly_meta(resources) 
        {
          page: @adminly_query.page,
          per_page: @adminly_query.per_page,
          total_count: resources.total_count 
        }
      end 

      def adminly_serialize(resources, includes: nil)
        Adminly::Serializer.render(resources, includes: includes)
      end 
  
      def parse_query_params
        @adminly_query = Adminly::QueryParams.new(params)      
      end
  
    end

  end 
end 