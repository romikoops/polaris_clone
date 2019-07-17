# frozen_string_literal: true

module RmsData
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
