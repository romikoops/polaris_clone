class PricingsController < ApplicationController
  before_action :require_login

  def index
    tenant = current_user.tenant
    @itineraries = tenant.itineraries
    @pricings = current_user.pricings
    response = Rails.cache.fetch("#{@pricings.cache_key}/pricings_index", expires_in: 12.hours) do
      @transports = TransportCategory.all.uniq
      detailed_itineraries = @itineraries
                                .map {|itin| itin.as_user_pricing_json(current_user))

      last_updated = @itineraries.first ? @itineraries.first.updated_at : DateTime.now
      {
        detailedItineraries: detailed_itineraries,
        transportCategories: @transports,
        lastUpdate:          last_updated
      }
    end
    response_handler(response)
  end

end
