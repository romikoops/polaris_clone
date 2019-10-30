# frozen_string_literal: true

module AddressBook
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
