# frozen_string_literal: true

module Legacy
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
