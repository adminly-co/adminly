module Adminly
  class ApiController < ApplicationController
    include Adminly::Scope

    skip_before_action :verify_authenticity_token

    before_action :load_adminly_record, except: [:query]

    def index
      resources = resource_scope
      authorize resources, :index?

      resources = adminly_scope(resources)

      render json: {
        data: adminly_serialize(resources, includes: @adminly_query.includes),
        meta: adminly_meta(resources)
      }
    end

    def show
      resource = resource_scope.find(params[:id])
      authorize resource, :show?
      render json: {
        data: adminly_serialize(resource, includes: @adminly_query.includes)
      }
    end

    def create
      resource = resource_scope.create!(adminly_params)
      authorize resource, :create?
      render json: {
        data: adminly_serialize(resource)
      }
    end

    def update
      resource = resource_scope.find(params[:id])
      authorize resource, :update?
      if resource.update(adminly_params)
        render json: {
          data: adminly_serialize(resource)
        }
      else
        render json: { error: resource.errors.full_messages }, status: 422
      end
    end

    def destroy
      resource = resource_scope.find(params[:id])
      authorize resource, :destroy?
      resource.destroy
      render json: { data: adminly_serialize(resource) }
    end

    def update_many
      resources = resource_scope.where(id: params[:ids])
      authorize resources, :update?
      resources.update(adminly_params)
      render json: { data: adminly_serialize(resources) }
    end

    def delete_many
      resources = resource_scope.where(id: params[:ids])
      authorize resources, :destroy?
      resources.destroy_all
      render json: { data: adminly_serialize(resources) }
    end

    def query
      sql = sql_query_params[:sql]
      rows = Adminly::SqlQuery.execute(sql)
      render json: {
        data: rows,
        meta: {
          page: 1,
          per_page: rows.length,
          total_count: rows.length,
        }
      }
    rescue Adminly::SqlQuery::QueryError
      render json: { error: 'Unpermitted query type' }, status: :unprocessable_entity
    rescue ActiveRecord::StatementInvalid => err
      render json: { error: 'Invalid SQL' }, status: :unprocessable_entity
    end

    private

    def load_adminly_record
      @adminly_record = AdminlyRecord.to_active_record(
        params[:table_name], 
        belongs_to: @adminly_query.belongs_to,
        has_many: @adminly_query.has_many,        
        habtm: @adminly_query.habtm        
      )
    end

    def resource_scope
      policy_scope(@adminly_record)
    end

    def adminly_params
      params.require(params[:table_name]).permit!
    end

    def sql_query_params
      params
        .require(:query)
        .permit(:sql)
    end 

  end
end
