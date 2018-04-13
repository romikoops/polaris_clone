class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
  def self.given_attribute_names
    attribute_names - %w(id created_at updated_at)
  end
  
  def given_attributes
    self.class.given_attribute_names.each_with_object({}) do |attr_name, return_h|
      return_h[attr_name.to_sym] = self[attr_name]
    end
  end

  def to_postgres_insertable
    self.class.given_attribute_names.map do |attr_name|
      val = self[attr_name]
      case val
      # when nil
      #   NULL
      when Hash
        "'#{val.to_json}'::jsonb"
      when String
        "'#{val}'"
      else
        val
      end
    end.sql_format
  end
end
