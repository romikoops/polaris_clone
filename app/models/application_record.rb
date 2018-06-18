# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.given_attribute_names
    attribute_names - %w[id created_at updated_at]
  end

  def given_attributes
    self.class.given_attribute_names.each_with_object({}) do |attr_name, return_h|
      return_h[attr_name.to_sym] = self[attr_name]
    end
  end

  def to_postgres_insertable(attribute_names=self.class.given_attribute_names)
    attribute_names.sort.map do |attr_name|
      val = self[attr_name]
      case val
      when nil
        "NULL"
      when Hash
        "'#{val.to_json}'::jsonb"
      when String
        "'#{val}'"
      when nil
        "NULL"
      else
        val
      end
    end.sql_format
  end

  def self.public_sanitize_sql(*args)
    sanitize_sql(*args)
  end

  def self.reset_all_tables_except(*models)
    Rails.application.eager_load!
    models_to_delete = ApplicationRecord.descendants - models
    models_to_delete.each_with_index do |model, i|
      if i > 1000
        puts "could not deletet the following models:
          #{models_to_delete[1001..-1].log_format}".red
        break
      end
      model.delete_all
    rescue StandardError
      models_to_delete << model
    end
    models_to_delete
  end

  def self.test_logic
    arr = [1, 2]
    arr.each do |elem|
      begin
        raise if elem < arr.last
      rescue
        arr << elem
      end
    end
    arr
  end

  private

  def sanitize_sql(*args)
    self.class.public_sanitize_sql(*args)
  end
end
