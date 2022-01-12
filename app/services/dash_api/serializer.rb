module DashApi 
  module Serializer 

    def self.render(current_scope, includes: nil)             
      if includes        
        current_scope.as_json(include: includes)
      else
        current_scope.as_json
      end 
    end 

  end 
end 