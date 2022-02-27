module Adminly 
  module Serializer 

    def self.render(current_scope, includes: [])             
      current_scope.as_json(include: includes&.map(&:downcase))
    end 

  end 
end 