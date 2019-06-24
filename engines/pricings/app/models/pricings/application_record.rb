# frozen_string_literal: true

module Pricings
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
