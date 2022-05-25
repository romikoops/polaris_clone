# frozen_string_literal: true

module Distributions
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
