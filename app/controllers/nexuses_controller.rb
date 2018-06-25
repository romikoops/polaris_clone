# frozen_string_literal: true

class NexusesController < ApplicationController
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
		nexus_ids = params[:nexus_ids].split(",").map(&:to_i)
		hub_ids = params[:hub_ids].split(",").map(&:to_i)
    target 	  = params[:target]
    
		itinerary_ids = params[:itinerary_ids].split(",").map(&:to_i)
    itineraries   = current_user.tenant.itineraries.where(id: itinerary_ids)
    available_nexus_ids = itineraries.map do |itinerary|
      if nexus_ids.blank? || nexus_ids.empty?
        itinerary.nexus_ids_for_target(target)
      else
        itinerary.available_counterpart_nexus_ids_for_target_nexus_ids(target, nexus_ids)
      end
    end.flatten.uniq
    
    Location.where(id: available_nexus_ids)		
	end

	def format_for_select_box(nexuses)
		nexuses.map do |nexus| 
			{ label: nexus[:name], value: nexus }
		end		
	end
end
