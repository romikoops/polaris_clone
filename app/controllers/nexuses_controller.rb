class NexusesController < ApplicationController
	skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!
	def index
		@available_destinations = find_available_destinations

		format_available_destinations_for_select_box!

		response_handler(available_destinations: @available_destinations)
	end

	def find_nexus
		geocoded_location = Location.new(latitude: params[:lat], longitude: params[:lng])
		nexus_data = geocoded_location.closest_location_with_distance
		nexus = nexus_data.first if nexus_data.last <= 200

		response_handler(nexus: nexus)
	end

	private

	def find_available_destinations 
		routes = Route.where(id: params[:route_ids].split(","))

		return routes.map(&:destination_nexus) if params[:origin].nil?

		origin = Location.geocoded_location params[:origin]
		origin_nexus_data = origin.closest_location_with_distance
		origin_nexus = origin_nexus_data.first if origin_nexus_data.last <= 200
		routes.where(origin_nexus: origin_nexus).map(&:destination_nexus).uniq
	end

	def format_available_destinations_for_select_box!
		@available_destinations.map! do |available_destination| 
			{ label: available_destination[:name], value: available_destination }
		end		
	end
end
