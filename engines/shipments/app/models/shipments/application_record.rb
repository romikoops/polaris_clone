# frozen_string_literal: true

module Shipments
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
