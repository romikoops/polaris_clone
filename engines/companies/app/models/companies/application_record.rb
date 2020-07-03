# frozen_string_literal: true

module Companies
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
