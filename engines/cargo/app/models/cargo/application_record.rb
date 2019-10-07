# frozen_string_literal: true

module Cargo
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
