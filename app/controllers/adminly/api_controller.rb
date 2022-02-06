module Adminly
  class ApiController < ApplicationController

    skip_before_action :verify_authenticity_token

    before_action :parse_query_params, except: [:query]
    before_action :load_adminly_record, except: [:query]

    def index
      resources = adminly_scope
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
        data: Adminly::Serializer.render(resources, includes: @includes),
        meta: {
          page: @page,
          per_page: @per_page,
          total_count: resources.respond_to?(:total_count) ? resources.total_count : 1
        }
      }
    end

    def query
      sql = params.require(:query).permit(:sql)[:sql]
      rows = Adminly::RawQuery.execute(sql)
      render json: {
        data: rows,
        meta: {
          page: 1,
          per_page: rows.length,
          total_count: rows.length,
        }
      }
    rescue Adminly::RawQuery::QueryError
      render json: { error: 'Unpermitted query type' }, status: :unprocessable_entity
    rescue ActiveRecord::StatementInvalid => err
      render json: { error: 'Invalid SQL' }, status: :unprocessable_entity
    end

    def show
      resource = adminly_scope.find(params[:id])
      authorize resource, :show?
      render json: {
        data: Adminly::Serializer.render(resource, includes: @includes)
      }
    end

    def create
      resource = adminly_scope.create!(adminly_params)
      authorize resource, :create?
      render json: {
        data: Adminly::Serializer.render(resource)
      }
    end

    def update
      resource = adminly_scope.find(params[:id])
      authorize resource, :update?
      if resource.update(adminly_params)
        render json: {
          data: Adminly::Serializer.render(resource)
        }
      else
        render json: { error: resource.errors.full_messages }, status: 422
      end
    end

    def destroy
      resource = adminly_scope.find(params[:id])
      authorize resource, :destroy?
      resource.destroy
      render json: { data: Adminly::Serializer.render(resource) }
    end

    def update_many
      resources = adminly_scope.where(id: params[:ids])
      authorize resources, :update?
      resources.update(adminly_params)
      render json: { data: Adminly::Serializer.render(resources) }
    end

    def delete_many
      resources = adminly_scope.where(id: params[:ids])
      authorize resources, :destroy?
      resources.destroy_all
      render json: { data: Adminly::Serializer.render(resources) }
    end

    private

    def parse_query_params
      query = Adminly::Query.parse(params)
      @keywords = query[:keywords]
      @page =query[:page]
      @per_page = query[:per_page]
      @order = query[:order]
      @filters = query[:filters]
      @stats = query[:stats]
      @select = query[:select_fields]
      @includes = query[:associations]
    end

    def load_adminly_record
      @adminly_record = AdminlyRecord.modelize(params[:table_name], includes: @includes)
    end

    def adminly_scope
      policy_scope(@adminly_record)
    end

    def adminly_params
      params.require(params[:table_name]).permit!
    end

  end
end
