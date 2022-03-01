module Adminly
  module Scope
    extend ActiveSupport::Concern

    included do

      before_action :parse_query_params

      def adminly_scope(resources)
        @adminly_query.filters.each do |filter|
          resources = resources.where(filter)
        end

        if @adminly_query.keywords? and resources.respond_to?(:pg_search)
          resources = resources.pg_search(@adminly_query.keywords)
        end

        resources = resources.includes(@adminly_query.includes) if @adminly_query.includes.any?
        resources = resources.order(@adminly_query.order) if @adminly_query.order?
        resources = resources.page(@adminly_query.page).per(@adminly_query.per_page)
        
        resources = group_by(resources, @adminly_query.group_by) if @adminly_query.group_by.any?
        resources = aggregate(resources, @adminly_query.select_fields) if @adminly_query.select_fields.any?        

        resources
      end

      def adminly_meta(resources)
        unless resources.respond_to? :total_count
          {
            page: @adminly_query.page,
            per_page: @adminly_query.per_page,
          }
        else
          {
            page: @adminly_query.page,
            per_page: @adminly_query.per_page,
            total_count: resources.total_count
          }
        end
      end

      def adminly_serialize(resources, includes: [])
        Adminly::Serializer.render(resources, includes: includes)
      end

      def parse_query_params
        @adminly_query = Adminly::QueryParams.new(params)
      end

      private

      def group_by(resources, params)
        return resources unless params.present?

        params.reduce(resources) do |resources, group_by_params|
          field, date_period = group_by_params

          if date_period.present?
            resources.group_by_period(date_period, field)
          else
            resources.group(field)
          end
        end
      end

      def aggregate(resources, params)
        params.reduce(resources) do |resources, select_params|
          field, agg = select_params
          if agg.present?
            resources.send(agg, field)
          else
            resources.select(field)
          end 
        end        
      end
          
    end    
  end
end
