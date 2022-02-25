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
    BOOLEANS = ["true","false", "null"]

    FUNCTIONS = {}
    # these are the date parts supported by Postgres
    [:microseconds, :milliseconds, :second, :minute, :hour, :day, :week, :month, :quarter, :year, :decade, :century, :millennium].each do |date_part|
      FUNCTIONS[date_part.to_s] = -> (column) { "date_trunc('#{date_part}', #{column})" }
    end
    [:avg, :sum, :min, :max, :count].each do |func_name|
      FUNCTIONS[func_name.to_s] = -> (column) { "#{func_name}(#{column})" }
    end

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
        select_fields = params[:select]&.split(',').map do |field|
          field, func = field.strip.split(DELIMITER)
          if func.present?
            "#{FUNCTIONS[func].(field)} AS #{field}"
          else
            field
          end
        end
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

    def belongs_to
      if @params[:belongs_to]
        associations = @params[:belongs_to].split(",").map(&:strip)
      end
      associations
    end

    def has_many
      if @params[:has_many]
        associations = @params[:has_many].split(",").map(&:strip)
      end
      associations
    end

    def habtm
      if @params[:habtm]
        associations = @params[:habtm].split(",").map(&:strip)
      end
      associations
    end

    def includes
      sanitize = proc { |rel| rel.split(":").first.downcase }

      includes_bt = belongs_to&.map(&sanitize)&.map(&:singularize)
      includes_hm = has_many&.map(&sanitize)
      includes_habtm = habtm&.map(&sanitize)
      [includes_bt, includes_hm, includes_habtm].flatten.compact
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

    def group_by
      group_by = []
      if @params[:group_by].present?
        group_by = @params[:group_by].split(",").map do |field|
          column, func = field.strip.split(DELIMITER)
          func.present? ? FUNCTIONS[func].(column) : column
        end
      end
      group_by
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
        belongs_to: belongs_to,
        has_many: has_many,
        habtm: habtm,
        filters: filters,
        includes: includes,
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

    def format_filter(filter_param)
      field, rel, value = filter_param.split(DELIMITER)
      rel = "eq" unless OPERATORS.keys.include?(rel.to_sym)
      operator = OPERATORS[rel.to_sym] || '='

      if value =~ DATE_REGEX
        value = DateTime.parse(value)
      end

      if BOOLEANS.include?(value.downcase)
        value = true if value.downcase === "true"
        value = false if value.downcase === "false"
        value = nil if value.downcase === "null"
      end

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
