class NexusesController < ApplicationController # TODO: mongo
	include ItineraryTools
	skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

	def index
		formatted_available_nexuses = format_for_select_box(find_available_nexuses)
		response_handler("available#{params[:target].capitalize}s" => formatted_available_nexuses )
	end

	def find_nexus
		geocoded_location = Location.new(latitude: params[:lat], longitude: params[:lng])
		nexus_data = geocoded_location.closest_location_with_distance
		nexus = nexus_data.first if nexus_data.last <= 200
		response_handler(nexus: nexus)
	end

	private

	def find_available_nexuses
		# Expects a params[:target] #=> "origin" or "destination"
		# Then the following variables are assigned:
		#
		#      target #=> "origin",      counterpart #=> "destination" 
		#  or  target #=> "destination", counterpart #=> "origin" 

		nexus_ids 			= params[:nexus_ids].split(",").map(&:to_i)
		target 					= params[:target]
		counterpart     = target == "destination" ? "origin" : "destination"

		itinerary_ids = params[:itinerary_ids].split(",").map(&:to_i)
		itineraries   = retrieve_route_options(current_user.tenant_id, itinerary_ids)

		if nexus_ids.blank? || nexus_ids.empty?
			return itineraries.map { |itinerary| Location.find(itinerary["#{target}_nexus_id"]) }.uniq
		end

		itineraries.select { |itinerary| nexus_ids.include? itinerary["#{counterpart}_nexus_id"] }
			.map { |itinerary| Location.find(itinerary["#{target}_nexus_id"]) }.uniq
	end

	def format_for_select_box(nexuses)
		nexuses.map do |nexus| 
			{ label: nexus[:name], value: nexus }
		end		
	end
end
