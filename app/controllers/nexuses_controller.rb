# frozen_string_literal: true

class NexusesController < ApplicationController
  include ItineraryTools
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def index
    formatted_available_nexuses = format_for_select_box(find_available_nexuses)
    response_handler("available#{params[:target].capitalize}Nexuses" => formatted_available_nexuses)
  end

  def find_nexus
    geocoded_address = Address.new(latitude: params[:lat], longitude: params[:lng])
    nexus_data = geocoded_address.closest_address_with_distance
    nexus = nexus_data.first if nexus_data.last <= 200
    response_handler(nexus: nexus)
  end

  private

  def find_available_nexuses
    nexus_ids = params[:nexus_ids].split(',').map(&:to_i)
    hub_ids   = params[:hub_ids].split(',').map(&:to_i)
    target    = params[:target]

    itinerary_ids = params[:itinerary_ids].split(',').map(&:to_i)
    itineraries = current_user.tenant.itineraries
                              .where(sandbox: @sandbox)
                              .joins(:stops)
                              .where(id: itinerary_ids)
                              .where('stops.hub_id': hub_ids)

    available_hub_ids = itineraries.map do |itinerary|
      if hub_ids.blank?
        itinerary.hub_ids_for_target(target)
      else
        itinerary.available_counterpart_hub_ids_for_target_hub_ids(target, hub_ids)
      end
    end.flatten.uniq

    Hub.group_ids_by_nexus(available_hub_ids)
  end

  def format_for_select_box(available_hub_ids_grouped_by_nexus)
    Address.where(id: available_hub_ids_grouped_by_nexus.keys).map do |nexus|
      {
        label: nexus[:name],
        value: nexus.as_json.merge(hub_ids: available_hub_ids_grouped_by_nexus[nexus.id])
      }
    end
  end
end
