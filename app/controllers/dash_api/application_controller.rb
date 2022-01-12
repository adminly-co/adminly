module DashApi
  class ApplicationController < ActionController::Base    
    include ApiException
    include Auth 

  end
end
