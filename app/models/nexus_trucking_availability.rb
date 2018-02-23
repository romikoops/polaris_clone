class NexusTruckingAvailability < ApplicationRecord
	belongs_to :trucking_availability
	belongs_to :tenant
	belongs_to :nexus, class_name: "Location"
end
