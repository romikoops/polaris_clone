# frozen_string_literal: true

class CorrectRelayBackfillSnafuWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    results = Journey::Result.where(id: Quotations::Tender.ids).joins(:result_set).joins(:route_sections).where(journey_result_sets: { status: "completed" })
    total results.count
    results.find_each.with_index do |result, index|
      at(index + 1)
      tender = Quotations::Tender.find_by(id: result.id)
      next if skip_result(result: result, tender: tender)

      freight_section = result.route_sections.where(mode_of_transport: "relay").find { |route_section| route_section.from.geo_id != route_section.to.geo_id }
      ActiveRecord::Base.transaction do
        freight_section.update(mode_of_transport: mode_of_transport_from(tender: tender))
        new_order = missing_order(result: result)
        point_to_dup = point_for_duplication(freight_section: freight_section, missing_order: new_order)
        Journey::RouteSection.create!(
          result: result,
          from: point_to_dup.dup,
          to: point_to_dup.dup,
          order: new_order,
          service: freight_section.service,
          carrier: freight_section.carrier,
          mode_of_transport: "relay",
          transit_time: 0
        )
      end
    end
  end

  def mode_of_transport_from(tender:)
    return "ocean" unless tender

    tender.itinerary&.mode_of_transport || tender.tenant_vehicle&.mode_of_transport || "ocean"
  end

  def missing_order(result:)
    order = result.route_sections.order(:order).pluck(:order)
    order.find { |step| order.exclude?(step + 1) } + 1
  end

  def point_for_duplication(freight_section:, missing_order:)
    missing_order > freight_section.order ? freight_section.to : freight_section.from
  end

  def invalid_original_data(tender:)
    tender.quotation.error_class.present? || !tender.line_items.exists?(section: :cargo_section)
  end

  def skip_result(result:, tender:)
    result.route_sections.exists?(mode_of_transport: %w[rail air ocean truck]) || invalid_original_data(tender: tender) || tender.quotation.organization.slug == "ifbhamburg"
  end
end
