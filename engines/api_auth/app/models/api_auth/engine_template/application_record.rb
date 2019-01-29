# frozen_string_literal: true

module ApiAuth
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
