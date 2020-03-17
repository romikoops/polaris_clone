# frozen_string_literal: true

module Quotations
  class LineItem < ApplicationRecord
    belongs_to :tender, inverse_of: :line_items
    belongs_to :charge_category, class_name: 'Legacy::ChargeCategory'
    enum section: { trucking_pre_section: 1,
                    export_section: 2,
                    cargo_section: 3,
                    import_section: 4, trucking_on_section: 5 }

    monetize :amount_cents
  end
end

# == Schema Information
#
# Table name: quotations_line_items
#
#  id                 :uuid             not null, primary key
#  amount_cents       :integer
#  amount_currency    :string
#  section            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  charge_category_id :bigint
#  tender_id          :uuid
#
# Indexes
#
#  index_quotations_line_items_on_charge_category_id  (charge_category_id)
#  index_quotations_line_items_on_tender_id           (tender_id)
#
