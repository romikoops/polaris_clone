# frozen_string_literal: true

module Ledger
  class Conflict < ApplicationRecord
    STRATEGIES = [INCOMING = "incoming", CURRENT = "current"].freeze
    enum resolution: STRATEGIES.zip(STRATEGIES).to_h

    belongs_to :book, class_name: "Ledger::Book"
    belongs_to :staged_rate, class_name: "Ledger::Rate"
    belongs_to :basis_rate, class_name: "Ledger::Rate"
    belongs_to :merged_rate, class_name: "Ledger::Rate", optional: true

    validates :basis_rate, uniqueness: { scope: :staged_rate_id }
    validates :merged_rate, uniqueness: { scope: %i[staged_rate_id merged_rate_id] }
    validates :resolution, presence: { if: -> { merged_rate.present? } },
      inclusion: { in: STRATEGIES, allow_blank: true }
  end
end

# == Schema Information
#
# Table name: ledger_conflicts
#
#  id             :uuid             not null, primary key
#  resolution     :enum
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  basis_rate_id  :uuid             not null
#  book_id        :uuid             not null
#  merged_rate_id :uuid
#  staged_rate_id :uuid             not null
#
# Indexes
#
#  index_ledger_conflicts_on_basis_rate_id   (basis_rate_id)
#  index_ledger_conflicts_on_book_id         (book_id)
#  index_ledger_conflicts_on_merged_rate_id  (merged_rate_id)
#  index_ledger_conflicts_on_staged_rate_id  (staged_rate_id)
#
