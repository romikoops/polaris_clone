# frozen_string_literal: true

module Files
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
