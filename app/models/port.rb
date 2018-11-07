class Port < ApplicationRecord
  belongs_to :nexus, class_name: "Location"
  belongs_to :address
  belongs_to :country
end
