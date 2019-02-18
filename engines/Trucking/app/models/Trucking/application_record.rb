# frozen_string_literal: true

module Trucking
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
    def self.given_attribute_names
      attribute_names - %w(id created_at updated_at)
    end
  end
end
