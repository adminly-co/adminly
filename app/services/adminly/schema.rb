module Adminly
  module Schema

    EXCLUDED_TABLES = [
      'ar_internal_metadata',
      'schema_migrations'
    ]

    attr_accessor :tables

    def self.table_names
      @tables = ActiveRecord::Base.connection.tables
      @tables.filter!{|t| !EXCLUDED_TABLES.include?(t)}
      @tables.sort!
    end

    def self.table_schema(table_name)
      @tables = table_names
      adminly_record = AdminlyRecord.modelize(table_name)
      adminly_record.reset_column_information
      adminly_record.columns.map{ |column|
        render_column(column)
      }
    end

    def self.db_schema
      @tables = table_names
      schema = {
        tables: @tables
      }
      @tables.each do |table_name|
        schema[table_name] = table_schema(table_name)
      end
      schema
    end

    def self.render_column(column)
      {
        friendly_name: column.human_name,
        name: column.name,
        type: column.type,
        array: column.array,
        default: column.default,
        limit: column.sql_type_metadata.limit,
        precision: column.sql_type_metadata.precision,
        foreign_key: foreign_key?(column.name),
        foreign_table: foreign_table(column.name),
        enum_values: enum_values(column),
      }
    end

    def self.foreign_key?(column_name)
      column_name[-2..-1]&.downcase === 'id' && column_name.downcase != 'id'
    end

    def self.foreign_table(column_name)
      table_prefix = column_name[0...-3]
      @tables.find{|t| t === table_prefix || t === table_prefix.pluralize }
    end

    def self.enum_values(column)
      return nil if column.type != :enum

      conn = ActiveRecord::Base.connection
      oid = conn.quote(column.sql_type_metadata.oid)

      conn
        .execute("SELECT enumlabel FROM pg_enum WHERE enumtypid = #{oid} ORDER BY enumsortorder")
        .pluck('enumlabel')
    end

  end
end
