require 'net/http'
require 'net/https'

module DashApi 
  module JsonWebToken
    require 'jwt'    
    
    JWT_ALGORITHM = 'HS256'

    def self.encode(payload:, expiration:)
      payload[:exp] = expiration || 15.minutes.from_now.to_i
      JWT.encode(payload, DashApi.jwt_secret, JWT_ALGORITHM)
    end

    def self.decode(jwt_token)
      if DashApi.disable_authentication
        return { role: 'guest' }
      else 
        jwt = JWT.decode(jwt_token, DashApi.jwt_secret, true, {
          algorithm: JWT_ALGORITHM
        })
        HashWithIndifferentAccess.new(jwt[0])
      end
    end

    def self.decode_unverified(jwt_token)
      HashWithIndifferentAccess.new(JWT.decode(jwt_token, nil, false)[0])
    end
  
  end
end