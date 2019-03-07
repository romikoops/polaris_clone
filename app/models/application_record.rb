# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include AwsConfig

  def self.given_attribute_names
    attribute_names - %w(id created_at updated_at)
  end

  def given_attributes
    self.class.given_attribute_names.each_with_object({}) do |attr_name, return_h|
      return_h[attr_name.to_sym] = self[attr_name]
    end
  end

  def to_postgres_insertable(attribute_names = self.class.given_attribute_names)
    to_postgres_array(attribute_names).sql_format
  end

  def to_postgres_array(attribute_names = self.class.given_attribute_names)
    attribute_names.sort.map do |attr_name|
      val = self[attr_name]
      case val
      when %w(created_at updated_at).include?(attr_name) && nil
        "'#{DateTime.now}'"
      when Hash
        "'#{val.to_json}'::jsonb"
      when String
        "'#{val}'"
      when nil
        'NULL'
      else
        val
      end
    end
  end

  def self.public_sanitize_sql(*args)
    sanitize_sql(*args)
  end

  private

  def sanitize_sql(*args)
    self.class.public_sanitize_sql(*args)
  end
end
