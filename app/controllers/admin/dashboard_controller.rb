# frozen_string_literal: true

class Admin::DashboardController < Admin::AdminBaseController
  # Number of shipments to be displayed on dashboard
  DASH_SHIPMENTS = 3

  # Number of itineraries to be displayed on dashboard
  DASH_ITINERARIES = 30

  def index
    response = Rails.cache.fetch("#{organization_results.cache_key}/dashboard_index", expires_in: 12.hours) {
      {
        itineraries: detailed_itineraries,
        hubs: hubs,
        shipments: {
          quoted: decorate_results(results: organization_results.order(created_at: :desc).limit(3))
            .map(&:legacy_index_json)
        },
        mapData: map_data
      }
    }
    response_handler(response)
  end

  private

  def map_data
    MapDatum.where(organization_id: current_organization.id).limit(100)
  end

  def hubs
    Hub.where(organization_id: current_organization.id)
      .limit(8)
      .map { |hub|
      { data: ResultFormatter::HubDecorator.new(hub), address: hub.address.to_custom_hash }
    }
  end

  def detailed_itineraries
    Itinerary
      .where(organization: current_organization)
      .limit(DASH_ITINERARIES)
      .map(&:as_options_json)
  end
end
