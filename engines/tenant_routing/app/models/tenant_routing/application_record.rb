# frozen_string_literal: true

module TenantRouting
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
