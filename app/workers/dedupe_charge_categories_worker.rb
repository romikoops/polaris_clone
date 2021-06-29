# frozen_string_literal: true

class DedupeChargeCategoriesWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  FailedDeduping = Class.new(StandardError)

  def perform
    charge_category_pairs = duplicates.select(:code, :organization_id).distinct
    pair_total_count = charge_category_pairs.length
    total pair_total_count

    charge_category_pairs.each_with_index do |record, index|
      invalid_charge_categories = Legacy::ChargeCategory.where(code: record.code, organization_id: record.organization_id, cargo_unit_id: nil).sort_by(&:created_at)
      valid_charge_category = invalid_charge_categories.shift
      update_invalid_charge_categories(valid_id: valid_charge_category.id, invalid_charge_categories: invalid_charge_categories)
      render_index = index + 1
      at render_index, "ChargeCategory #{valid_charge_category.name} #{render_index} / #{pair_total_count} done"
    end

    raise FailedDeduping unless duplicates.empty?
  end

  def update_invalid_charge_categories(valid_id:, invalid_charge_categories:)
    ActiveRecord::Base.transaction do
      # rubocop:disable Rails/SkipsModelValidations
      Legacy::Charge.where(charge_category: invalid_charge_categories).update_all(charge_category_id: valid_id)
      Legacy::Charge.where(children_charge_category: invalid_charge_categories).update_all(children_charge_category_id: valid_id)
      Pricings::Breakdown.where(charge_category: invalid_charge_categories).update_all(charge_category_id: valid_id)
      Pricings::Detail.where(charge_category: invalid_charge_categories).update_all(charge_category_id: valid_id)
      Pricings::Fee.where(charge_category: invalid_charge_categories).update_all(charge_category_id: valid_id)
      Quotations::LineItem.where(charge_category: invalid_charge_categories).update_all(charge_category_id: valid_id)
      # rubocop:enable Rails/SkipsModelValidations
      invalid_charge_categories.each(&:destroy!)
    end
  end

  def duplicates
    Legacy::ChargeCategory.where("(select count(*) from charge_categories inr where inr.code = charge_categories.code AND inr.organization_id = charge_categories.organization_id AND cargo_unit_id IS NULL) > 1 AND cargo_unit_id IS NULL")
  end
end
