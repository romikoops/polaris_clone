# frozen_string_literal: true

module ApiDocs
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
