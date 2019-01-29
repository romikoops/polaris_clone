# frozen_string_literal: true

module Mailers
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
