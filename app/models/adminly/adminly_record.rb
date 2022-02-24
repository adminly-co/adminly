module Adminly 
  class AdminlyRecord < ApplicationRecord   
    include PgSearch::Model 
    include Adminly::Record     
    
    self.abstract_class = true    
    
  end 
end