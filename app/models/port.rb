class Port < ApplicationRecord
  belongs_to :nexus, class_name: "Location"
  belongs_to :location
  belongs_to :country
end
