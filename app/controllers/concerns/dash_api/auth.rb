module DashApi 
  module Auth   
    extend ActiveSupport::Concern

    included do
      
      private      

      def current_user
        jwt_payload = jwt_token 
        HashWithIndifferentAccess.new(jwt_payload)
      end 
  
      def jwt_token            
        DashApi::JsonWebToken.decode(auth_token)         
        rescue JWT::ExpiredSignature
          raise "JWT token has expired"
        rescue JWT::VerificationError, JWT::DecodeError
          raise "Invalid JWT token"     
      end 
  
      def auth_token
        http_token || params['token']      
      end
    
      def http_token
        if request.headers['Authorization'].present?
          request.headers['Authorization'].split(' ').last
        end
      end  

    end

  end 
end 