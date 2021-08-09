# frozen_string_literal: true

class BackfillCarrierAttributesWithNamesWorker
  include Sidekiq::Worker

  def perform(*_args)
    Routing::Carrier.where(code: Journey::RouteSection.select(:carrier).distinct).find_each do |carrier|
      Journey::RouteSection.where(carrier: carrier.code).update_all(carrier: carrier.name)
    end
  end
end
