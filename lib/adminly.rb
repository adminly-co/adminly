require "adminly/version"
require "adminly/engine"

module Adminly    
  mattr_accessor :jwt_secret 
  mattr_accessor :disable_authentication  
end
