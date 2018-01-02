class Vehicle < ApplicationRecord
  has_many :transport_categories
  has_many :schedules
end
