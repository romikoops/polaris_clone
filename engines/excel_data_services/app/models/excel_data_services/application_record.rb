# frozen_string_literal: true

module ExcelDataServices
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
