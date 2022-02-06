module Adminly
  class ApplicationController < ActionController::Base    
    include ApiException
    include Auth 

  end
end
