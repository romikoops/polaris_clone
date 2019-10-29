# frozen_string_literal: true

module Sequential
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
