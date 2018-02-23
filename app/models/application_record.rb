class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def given_attributes
    self.class.given_attribute_names.each_with_object({}) do |attr_name, return_h|
      return_h[attr_name.to_sym] = self[attr_name]
    end
  end

  def self.given_attribute_names
    attribute_names - %w(id created_at updated_at)
  end
end
