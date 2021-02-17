class RemoveQuotationsWithoutNexusesWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(*args)
    quotations = Quotations::Quotation.where("
      quotations_quotations.destination_nexus_id not in
        (select id
          from nexuses)
      or
      quotations_quotations.origin_nexus_id not in
        (select id
          from nexuses)
      ")

    tenders = Quotations::Tender.where(quotation: quotations)

    Shipments::ShipmentRequest.where(tender: tenders).destroy_all
    quotations.destroy_all
  end
end
