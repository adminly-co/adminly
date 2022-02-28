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
        resources = resources.select(@adminly_query.select.map(&:first)) if @adminly_query.select?
        resources = resources.page(@adminly_query.page).per(@adminly_query.per_page)
        resources = group_by(resources, @adminly_query.group_by)
        resources = aggregate(resources, @adminly_query.select)

        resources
      end

      def adminly_meta(resources)
        if resources.is_a?(Hash)
          # this is the case when aggregating
          {}
        else
          # resources is a scope
          {
            page: @adminly_query.page,
            per_page: @adminly_query.per_page,
            total_count: resources.total_count
          }
        end
      end

      def adminly_serialize(resources, includes: nil)
        Adminly::Serializer.render(resources, includes: includes)
      end

      def parse_query_params
        @adminly_query = Adminly::QueryParams.new(params)
      end

      private

      def group_by(resources, params)
        return resources unless params.present?

        params.reduce(resources) do |resources, grouping|
          field, date_period = grouping

          if date_period.present?
            resources.group_by_period(date_period, field)
          else
            resources.group(field)
          end
        end
      end

      def aggregate(resources, select)
        if select.present?
          # `select` should only have a single field w/ aggregation present (others will be ignored)
          params = select.find { |field, agg| agg.present? }
          field, agg = params
          resources.send(agg, field)
        else
          resources
        end
      end
    end
  end
end
