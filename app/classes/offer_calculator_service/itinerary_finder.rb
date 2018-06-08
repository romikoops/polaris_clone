module OfferCalculatorService
  class ItineraryFinder < Base
    def exec(hubs)
      tenant_itineraries = @shipment.tenant.itineraries
      itineraries = tenant_itineraries.filter_by_hubs(hubs[:origin].ids, hubs[:destination].ids)
      raise ApplicationError::NoRoute if itineraries.nil?
      itineraries
    end
  end
end
