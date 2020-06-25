# frozen_string_literal: true

module Quotations
  class LineItem < ApplicationRecord
    belongs_to :tender, inverse_of: :line_items
    belongs_to :charge_category, class_name: 'Legacy::ChargeCategory'
    belongs_to :cargo, polymorphic: true, optional: true
    enum section: { trucking_pre_section: 1,
                    export_section: 2,
                    cargo_section: 3,
                    import_section: 4,
                    trucking_on_section: 5,
                    customs_section: 6,
                    insurance_section: 7,
                    addons_section: 8}

    monetize :amount_cents
    monetize :original_amount_cents

    delegate :code, to: :charge_category
  end
end

# == Schema Information
#
# Table name: quotations_line_items
#
#  id                       :uuid             not null, primary key
#  amount_cents             :integer
#  amount_currency          :string
#  cargo_type               :string
#  original_amount_cents    :integer
#  original_amount_currency :string
#  section                  :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  cargo_id                 :integer
#  charge_category_id       :bigint
#  tender_id                :uuid
#
# Indexes
#
#  index_quotations_line_items_on_cargo_type_and_cargo_id  (cargo_type,cargo_id)
#  index_quotations_line_items_on_charge_category_id       (charge_category_id)
#  index_quotations_line_items_on_tender_id                (tender_id)
#
