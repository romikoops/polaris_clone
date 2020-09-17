# frozen_string_literal: true

class BackfillSources < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    Pricings::Breakdown.find_each do |breakdown|
      next if breakdown.margin_id.nil?

      source = Pricings::Margin.find_by(id: breakdown.margin_id) || Pricings::Detail.find_by(id: breakdown.margin_id)
      breakdown.update_columns(source_id: source.id, source_type: source.class.to_s) if source.present?
    end
  end
end
