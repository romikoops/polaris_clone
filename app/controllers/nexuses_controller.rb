class NexusesController < ApplicationController
	include ItineraryTools
	skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!
	def index
		formatted_available_nexuses = format_for_select_box(find_available_nexuses)
		response_handler("available_#{params[:target]}" => formatted_available_nexuses )
	end

	def find_nexus
		geocoded_location = Location.new(latitude: params[:lat], longitude: params[:lng])
		nexus_data = geocoded_location.closest_location_with_distance
		nexus = nexus_data.first if nexus_data.last <= 200

		response_handler(nexus: nexus)
	end

	private

	# def find_available_destinations 
	# 	# itineraries = Itinerary.where(id: params[:itinerary_ids].split(","))
	# 	ids = params[:itinerary_ids].split(",").map { |e| e.to_i }
	# 	itineraries = retrieve_route_options(current_user.tenant_id, ids)
	# 	# byebug
	# 	return itineraries.map{ |itinerary| Location.find(itinerary["destination_nexus_id"])} if params[:origin].nil?

	# 	origin = Location.geocoded_location params[:origin]
	# 	origin_nexus_data = origin.closest_location_with_distance
	# 	origin_nexus = origin_nexus_data.first if origin_nexus_data.last <= 200
	# 	itineraries.reject {|itinerary| itinerary["origin_nexus_id"] != origin_nexus.id}.map { |itinerary2| Location.find(itinerary2["destination_nexus_id"])  }.uniq
	# end

	def find_available_nexuses
		itinerary_ids = params[:itinerary_ids].split(",").map(&:to_i)
		itineraries   = retrieve_route_options(current_user.tenant_id, itinerary_ids)

		user_input = params[:user_input]
		target = params[:target]
		source = target == "destination" ? "origin" : "destination"

		return itineraries.map { |itinerary| Location.find(itinerary["#{target}_nexus_id"])} if params[:user_input].nil?

		user_input = Location.geocoded_location params[:user_input]
		nexus_data = user_input.closest_location_with_distance
		nexus = nexus_data.first if nexus_data.last <= 200
		itineraries.select { |itinerary| itinerary["#{source}_nexus_id"] == nexus.id }
			.map { |itinerary| Location.find(itinerary["#{source}_nexus_id"]) }.uniq
	end

	def format_for_select_box(nexuses)
		nexuses.map do |nexus| 
			{ label: nexus[:name], value: nexus }
		end		
	end
end
