require "dash_api/version"
require "dash_api/engine"

module DashApi    
  mattr_accessor :jwt_secret 
  mattr_accessor :disable_authentication  
end
