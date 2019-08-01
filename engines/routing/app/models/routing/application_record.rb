# frozen_string_literal: true

module Routing
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
