  module Adminly 
    module Query 

    PER_PAGE = 20

    SORT_DIRECTIONS = ['asc', 'desc']

    DELIMITER = ":"

    OPERATORS = {
      "gt": ">",
      "gte": ">=",
      "lt": "<",
      "lte": "<=",
      "eq": "=",
      "neq": "!="
    }

    # perform
    # @params params 
    #
    # Adminly::Query is a helper module which parses URL parameters 
    # passed to a Rails Controller into attributes used to query a AdminlyRecord 

    def self.parse(params)       
      
      keywords = params[:keywords]
      
      if params[:select]
        select_fields = params[:select]&.split(',')
      end 
      
      if params[:order]        
        sort_by, sort_direction = params[:order].split(DELIMITER)        
        sort_direction = "desc" if sort_direction and !SORT_DIRECTIONS.include?(sort_direction)
        order = { "#{sort_by}": sort_direction }
      end 

      if params[:includes] 
        associations = params[:includes].split(",").map(&:strip)
      end 

      filters = []      
      if params[:filters]
        params[:filters].split(',').each do |filter_param|             
          filters << format_filter(filter_param)
        end  
      end 

      stats = nil
      if params[:max]
        stats = {maximum: params[:max]}
      end 

      if params[:min]
        stats = {minimum: params[:min]}
      end 

      if params[:avg]
        stats = {average: params[:avg]}
      end 

      if params[:count]
        stats = {count: params[:count]}
      end 


      page = params[:page]&.to_i || 1 
      per_page = params[:per_page]&.to_i || PER_PAGE 

      {
        associations: associations,
        filters: filters,
        keywords: keywords,
        order: order,
        page: page,
        per_page: per_page, 
        select_fields: select_fields,        
        sort_by: sort_by,
        sort_direction: sort_direction,        
        stats: stats
      }
    end 

    def self.format_filter(filter_param)
      field, rel, value = filter_param.split(DELIMITER)
      rel = "eq" unless OPERATORS.keys.include?(rel.to_sym)      
      operator = OPERATORS[rel.to_sym] || '='   
      condition = "#{field} #{operator} ?"
      [condition, value]
    end 

  end
end 
