# frozen_string_literal: true

module Notifications
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
