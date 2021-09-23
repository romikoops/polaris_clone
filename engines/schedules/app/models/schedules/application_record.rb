# frozen_string_literal: true

module Schedules
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
