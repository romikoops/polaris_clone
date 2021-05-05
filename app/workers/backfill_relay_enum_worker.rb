# frozen_string_literal: true

class BackfillRelayEnumWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(*_args)
    mots = %w[ocean air rail truck]
    total Journey::Result.count
    Journey::Result.find_each.with_index do |result, index|
      at(index + 1)
      route_sections_in_order = result.route_sections.order(:order)
      next if route_sections_in_order.length == 1 || route_sections_in_order.empty?

      route_sections_in_order.second.update(mode_of_transport: "relay") if route_sections_in_order.first.mode_of_transport == "carriage"
      route_sections_in_order.second_to_last.update(mode_of_transport: "relay") if route_sections_in_order.last.mode_of_transport == "carriage"

      next if route_sections_in_order.first.mode_of_transport == "carriage" && route_sections_in_order.last.mode_of_transport == "carriage"

      remaining_route_sections = route_sections_in_order.where(mode_of_transport: mots)
      next if remaining_route_sections.count == 1

      if remaining_route_sections.length == 3
        remaining_route_sections.first.update(mode_of_transport: "relay")
        remaining_route_sections.last.update(mode_of_transport: "relay")
        next
      end

      remaining_route_sections.each do |route_section|
        next if route_section.from.geo_id != route_section.to.geo_id && route_section.from.geo_id != "deleted"

        tender_line_items = Quotations::LineItem.where(tender_id: result.id)
        applicable_line_items = tender_line_items.joins(:charge_category).where(charge_categories: { code: route_section.line_items.select(:fee_code) })
        applicable_line_items = tender_line_items.where(amount_cents: route_section.line_items.select(:total_cents)) if applicable_line_items.empty?
        route_section.update(mode_of_transport: "relay") if route_section.from.geo_id != "deleted" || applicable_line_items.first.section.match?(/export|import/)
      end
    end
  end
end
