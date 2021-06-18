# frozen_string_literal: true

class BackfillLineItemSetReferenceWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    references = Quotations::Tender.where.not(imc_reference: nil).select(:imc_reference).distinct.pluck(:imc_reference)
    native_line_item_sets = Journey::LineItemSet.where.not(result_id: Quotations::Tender.ids)
    reference_count = references.count
    native_count = native_line_item_sets.count
    total reference_count + native_count
    references.each_with_index do |reference, index|
      at(index + 1, "Ref: #{reference}")
      tenders = Quotations::Tender.joins(:quotation).where(imc_reference: reference).order("quotations_quotations.billing ASC, created_at ASC").to_a
      ActiveRecord::Base.transaction do
        tenders.each_with_index do |iterative_tender, tender_index|
          new_ref = tender_index.zero? ? reference : "#{reference}##{tender_index}"
          iterative_tender.imc_reference = new_ref
          if tender_index.positive? && safe_to_override_validations(tender: iterative_tender)
            iterative_tender.save!(validate: false)
          elsif tender_index.positive?
            iterative_tender.save!
          end
          Journey::LineItemSet.where(result_id: iterative_tender.id)
            .order(created_at: :desc)
            .find_each.with_index do |line_item_set, line_item_set_index|
            line_item_set.update!(
              reference: line_item_set_index.zero? ? new_ref : "#{new_ref}/#{line_item_set_index}"
            )
          end
        end
      end
    end
    cumulative_index = reference_count
    Journey::LineItemSet.where(reference: nil).group_by(&:result_id).each_value do |line_item_sets|
      ActiveRecord::Base.transaction do
        line_item_sets.sort_by(&:created_at).reverse_each.with_index do |line_item_set, line_item_set_index|
          line_item_set.update(
            reference: Journey::ImcReference.new(
              date: line_item_set_index.zero? ? line_item_set.result.created_at : line_item_set.created_at
            ).reference
          )
        end
      end
      cumulative_index += line_item_sets.count
      at(cumulative_index, "New Ref #{cumulative_index}")
    end
  end

  def safe_to_override_validations(tender:)
    !tender.valid? && tender.errors.details.keys.exclude?(:imc_reference)
  end
end
