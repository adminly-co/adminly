module Adminly 
  class AdminlyRecord < ApplicationRecord   
    include PgSearch::Model 
    include Adminly::Collection     
    
    self.abstract_class = true    
    
  end 
end