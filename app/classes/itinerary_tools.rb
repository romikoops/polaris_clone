# frozen_string_literal: true

module ItineraryTools
  def get_itineraries_with_dedicated_pricings(user_id, tenant_id)
    itinerary_ids = User.find(user_id).pricings.where(tenant_id: tenant_id).pluck(:itinerary_id)
    Itinerary.where(id: itinerary_ids)
  end

  def get_itinerary_pricings(itinerary_id, transport_category_ids)
    Pricing.where(itinerary_id: itinerary_id, transport_category_id: transport_category_ids)
  end

  def get_itineraries(tenant_id)
    Itinerary.where(tenant_id: tenant_id).map(&:as_options_json)
  end

  def get_scoped_itineraries(tenant_id, mot_scope_ids)
    Itinerary.where(tenant_id: tenant_id, mot_scope_id: mot_scope_ids).map(&:as_options_json)
  end

  def retrieve_route_options(tenant_id, ids)
    Itinerary.where(tenant_id: tenant_id, id: ids).map(&:as_options_json)
  end
end
