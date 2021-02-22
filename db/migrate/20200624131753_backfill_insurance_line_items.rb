# frozen_string_literal: true
class BackfillInsuranceLineItems < ActiveRecord::Migration[5.2]
  def up
    [
      {code: "import_customs", enum: 6},
      {code: "export_customs", enum: 6},
      {code: "freight_insurance", enum: 7},
      {code: "customs_export_paper", enum: 8}
    ].each do |section|
      exec_update <<-SQL
          INSERT INTO quotations_line_items(
            amount_cents,
            amount_currency,
            original_amount_cents,
            original_amount_currency,
            charge_category_id,
            tender_id,
            section,
            created_at,
            updated_at
            )
          SELECT
            edited_prices.value * 100,
            edited_prices.currency,
            prices.value * 100,
            prices.currency,
            charges.children_charge_category_id,
            charge_breakdowns.tender_id,
            #{section[:enum]},
            charges.created_at,
            charges.updated_at
          FROM charges
          LEFT JOIN prices ON charges.price_id = prices.id
          LEFT JOIN prices as edited_prices ON charges.edited_price_id = prices.id
          LEFT JOIN charge_categories ON charges.children_charge_category_id = charge_categories.id
          LEFT JOIN charge_breakdowns ON charges.charge_breakdown_id = charge_breakdowns.id
          WHERE charge_categories.code = '#{section[:code]}'
      SQL
    end
  end

  def down
    Quotations::LineItem.where(section: %i[customs_section insurance_section addons_section]).delete_all
  end
end
