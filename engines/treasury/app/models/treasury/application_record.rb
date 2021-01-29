# frozen_string_literal: true

module Treasury
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
