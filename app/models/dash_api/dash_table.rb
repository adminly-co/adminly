module DashApi 
  class DashTable < ApplicationRecord   
    include PgSearch::Model 
    include DashApi::DashModel     
    
    self.abstract_class = true    
    
  end 
end