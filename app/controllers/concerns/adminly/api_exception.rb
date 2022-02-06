module Adminly 
  module ApiException  
    extend ActiveSupport::Concern

    included do
      include Pundit 

      rescue_from Exception, with: :unprocessable_entity
      rescue_from StandardError, with: :unprocessable_entity
      rescue_from ActiveRecord::RecordNotFound, with: :unprocessable_entity
      rescue_from ActiveRecord::ActiveRecordError, with: :unprocessable_entity        
      rescue_from Pundit::NotAuthorizedError, with: :unauthorized
        
      def unprocessable_entity(e)
        render json: { error: e }, status: :unprocessable_entity
      end    

      def unauthorized(e)
        render json: { error: "You are not authorized to perform this action." }, status: :unprocessable_entity
      end 
  
    end

  end 
end 
