module Adminly
  class QueryParams 

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

    DATE_REGEX = /\d{4}-\d{2}-\d{2}/

    # QueryParams is a ruby Class which parses URL parameters 
    # passed to a Rails Controller into attributes used to query models 
    attr_accessor :params 

    def initialize(params)
      @params = params 
    end 

    def keywords 
      @params[:keywords]
    end 

    def select 
      if @params[:select]
        select_fields = params[:select]&.split(',')
      end 
      select_fields
    end 

    def order 
      if @params[:order]        
        sort_by, sort_direction = @params[:order].split(DELIMITER)        
        sort_direction = "desc" if sort_direction and !SORT_DIRECTIONS.include?(sort_direction)
        order = { "#{sort_by}": sort_direction }
      end 
      order 
    end 

    def includes 
      if @params[:includes] 
        associations = @params[:includes].split(",").map(&:strip)
      end 
      associations
    end 

    def filters 
      filters = []      
      if @params[:filters]
        @params[:filters].split(',').each do |filter_param|             
          filters << format_filter(filter_param)
        end  
      end
      filters 
    end  

    def stats 
      stats = nil
      if @params[:max]
        stats = {maximum: @params[:max]}
      end 

      if @params[:min]
        stats = {minimum: @params[:min]}
      end 

      if @params[:avg]
        stats = {average: @params[:avg]}
      end 

      if @params[:count]
        stats = {count: @params[:count]}
      end 
      stats 
    end   

    def page 
      @params[:page]&.to_i || 1 
    end 

    def per_page 
      @params[:per_page]&.to_i || PER_PAGE 
    end 

    def to_hash
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

    def page_info(paginated_scope)
      total_count = paginated_scope.total_count
      {
        page: paginated_scope.current_page,
        num_pages: (total_count / per_page).to_i + 1,
        per_page: per_page,
        total_count: total_count
      }
    end

    def format_filter(filter_param)
      field, rel, value = filter_param.split(DELIMITER)
      rel = "eq" unless OPERATORS.keys.include?(rel.to_sym)      
      operator = OPERATORS[rel.to_sym] || '='         
      value = DateTime.parse(value) if value =~ DATE_REGEX
      condition = "#{field} #{operator} ?"
      [condition, value]
    end 

    def stats?
      stats ? true : false
    end 

    def order?
      order ? true : false
    end 

    def keywords?
      keywords ? true : false
    end 

    def includes? 
      includes ? true : false
    end 

    def select?
      select ? true : false
    end 

  end
end
