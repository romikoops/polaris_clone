# frozen_string_literal: true

module Groups
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
