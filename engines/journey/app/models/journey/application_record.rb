# frozen_string_literal: true

module Journey
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
