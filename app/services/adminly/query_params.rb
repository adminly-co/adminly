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
      "neq": "!=",
      "in": "in",
    }

    DATE_REGEX = /\d{4}-\d{2}-\d{2}/
    BOOLEANS = ["true","false", "null"]

    # comma not inside square braces
    FILTER_DELIMITER = /
        ,         # match comma
        (?!       # if not followed by
        [^\[]*    # anything except an open brace [
        \]        # followed by a closing brace ]
        )         # end lookahead
    /x

    DATE_PERIODS = [
      :second,
      :minute,
      :hour,
      :day,
      :week,
      :month,
      :quarter,
      :year
    ]

    AGGREGATIONS = {
      avg: "average",
      sum: "sum",
      min: "minimum",
      max: "maximum",
      count: "count"
    }

    # QueryParams is a ruby Class which parses URL parameters
    # passed to a Rails Controller into attributes used to query models
    attr_accessor :params

    def initialize(params)
      @params = params
    end

    def keywords
      if @params[:keywords]&.include?(DELIMITER)
        @params[:keywords].split(DELIMITER)
      else
        @params[:keywords]
      end
    end

    def select_fields
      select_params = []
      if @params[:select]
        select_params = @params[:select]&.split(',').map do |field|
          field, agg = field.strip.split(DELIMITER)
          if agg.present? && AGGREGATIONS.keys.include?(agg.to_sym)
            aggregation = AGGREGATIONS[agg.to_sym]
            [field, aggregation]
          else
            [field]
          end
        end
      end
      select_params
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
      field_name = proc { |rel| rel.split(":").first }

      includes_bt = belongs_to&.map(&field_name)
      includes_hm = has_many&.map(&field_name)
      includes_habtm = habtm&.map(&field_name)
      [includes_bt, includes_hm, includes_habtm].flatten.compact
    end

    def filters
      filters = []
      if @params[:filters]
        @params[:filters].split(FILTER_DELIMITER).each do |filter_param|
          filters << format_filter(filter_param)
        end
      end
      filters
    end

    def group_by
      group_params = []
      if @params[:group_by].present?
        group_params = @params[:group_by].split(",").map do |field|
          field, date_period = field.strip.split(DELIMITER)
          if date_period.present? && DATE_PERIODS.include?(date_period.to_sym)
            [field, date_period]
          else
            [field]
          end
        end
      end
      group_params
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
        group_by: group_by,
        includes: includes,
        keywords: keywords,
        order: order,
        page: page,
        per_page: per_page,
        select_fields: select_fields,
        sort_by: sort_by,
        sort_direction: sort_direction
      }
    end

    def format_filter(filter_param)
      field, rel, value = filter_param.split(DELIMITER)
      rel = "eq" unless OPERATORS.keys.include?(rel.to_sym)
      operator = OPERATORS[rel.to_sym] || '='

      if rel == 'in'
        value = JSON.parse(value).map { |v| transform_value(v) }
      else
        value = transform_value(value)
      end

      condition = "#{field} #{operator} (?)"
      [condition, value]
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
      select_fields ? true : false
    end

    private

    def transform_value(value)
      if value =~ DATE_REGEX
        value = DateTime.parse(value)
      elsif value.respond_to?(:downcase) && BOOLEANS.include?(value&.downcase)
        value = true if value.downcase === "true"
        value = false if value.downcase === "false"
        value = nil if value.downcase === "null"
      end

      value
    end
  end
end
