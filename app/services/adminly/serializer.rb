module Adminly 
  module Serializer 

    def self.render(current_scope, includes: nil)             
      current_scope.as_json(include: includes)
    end 

  end 
end 