# frozen_string_literal: true

module CmsData
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
