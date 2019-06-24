# frozen_string_literal: true

class IsModelValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    @record    = record
    @attribute = attribute

    camelized_value = value.camelize
    unless camelized_value.safe_constantize.ancestors.include?(ActiveRecord::Base)
      add_error "#{camelized_value} is not a valid model"
    end
  end

  private

  def add_error(message)
    @record.errors[@attribute] << message
  end
end
