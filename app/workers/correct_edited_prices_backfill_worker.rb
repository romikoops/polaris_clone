# frozen_string_literal: true

class CorrectEditedPricesBackfillWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    edited_tenders = Quotations::Tender.joins(:line_items).where("quotations_line_items.original_amount_cents != quotations_line_items.amount_cents")
    total edited_tenders.count
    edited_tenders.find_each.with_index do |tender, index|
      at(index + 1)
      result = ResultFormatter::ResultDecorator.new(Journey::Result.find(tender.id))

      tender.line_items.each do |tender_line_item|
        correct_line_item(tender_line_item: tender_line_item, result: result)
      end
    end
  end

  def correct_line_item(tender_line_item:, result:)
    result.line_item_sets.order(:created_at).each_with_index do |line_item_set, index|
      journey_line_item = line_item_set.line_items.find_by(
        fee_code: tender_line_item.code,
        route_section: route_section_from_legacy_enum(result: result, enum: tender_line_item.section)
      )
      next if journey_line_item.blank?

      amount = index.zero? ? tender_line_item.original_amount : tender_line_item.amount
      journey_line_item.update(total: amount)
    end
  end

  def route_section_from_legacy_enum(result:, enum:)
    case enum
    when /trucking_pre/
      result.pre_carriage_section
    when /trucking_on/
      result.on_carriage_section
    when /export/
      result.origin_transfer_section
    when /import/
      result.destination_transfer_section
    when /cargo/
      result.main_freight_section
    end
  end
end
