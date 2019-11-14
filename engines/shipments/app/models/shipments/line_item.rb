# frozen_string_literal: true

module Shipments
  class LineItem < ApplicationRecord
    has_paper_trail unless: proc { |t| t.sandbox_id.present? }

    belongs_to :invoice
  end
end

# == Schema Information
#
# Table name: shipments_line_items
#
#  id              :uuid             not null, primary key
#  amount_cents    :integer          default(0), not null
#  amount_currency :string           not null
#  fee_code        :string
#  cargo_id        :uuid
#  invoice_id      :uuid             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
