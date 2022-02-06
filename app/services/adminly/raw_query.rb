module Adminly
  module RawQuery
    class QueryError < StandardError; end

    def self.execute(sql)
      sql = sanitize(sql)
      ActiveRecord::Base.connection.select_all(sql)
    end

    def self.sanitize(sql)
      tokens = sql.split(/\s/)

      # only allow select statements
      if tokens[0].downcase != 'select'
        raise QueryError
      end

      # remove semicolons to prevent the chaining of multiple statements
      sql = sql.gsub(';', '')

      sql
    end
  end
end
