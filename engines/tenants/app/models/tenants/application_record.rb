# frozen_string_literal: true

module Tenants
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
