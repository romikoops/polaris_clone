# frozen_string_literal: true

module Ledger
  class Rate < ApplicationRecord
    RATE_BASIS_LIST = %w[cbm kg stowage km shipment unit wm percentage].freeze

    monetize :rate_cents, with_model_currency: :rate_currency, numericality: { greater_than: 0 }, allow_nil: false
    monetize :min_cents, with_model_currency: :min_currency, allow_nil: true,
      numericality: { greater_than_or_equal_to: 0 }
    monetize :max_cents, with_model_currency: :max_currency, allow_nil: true,
      numericality: { greater_than: 0 }

    belongs_to :book_routing, class_name: "Ledger::BookRouting"
    belongs_to :group, class_name: "Groups::Group", optional: true
    has_and_belongs_to_many :books, class_name: "Ledger::Book"

    validates :validity, presence: true
    validate :validity_correctness, if: ->(r) { r.book_routing.present? }
    validates :rate_cents, presence: true
    validates :rate_currency, presence: true
    validates_enum :rate_basis, allow_nil: true
    validates :fee_code, presence: true, uniqueness: { scope: %i[book_routing_id validity] }
    validates :fee_name, presence: true, uniqueness: { scope: %i[book_routing_id validity] }

    scope :without_rate, ->(rate_id) { where.not(id: rate_id) }
    scope :overlapped_rates, lambda { |rate_id, validity|
      without_rate(rate_id).where("validity && daterange(?,?)", validity.min, validity.max)
    }

    private

    def validity_correctness
      return unless book_routing.rates.overlapped_rates(id, validity).exists?

      errors.add(:validity, "must not be overlapped with other rates for the book routing")
    end
  end
end

# == Schema Information
#
# Table name: ledger_rates
#
#  id              :uuid             not null, primary key
#  cbm_range       :numrange
#  density_range   :numrange
#  fee_code        :string           not null
#  fee_name        :string           not null
#  kg_range        :numrange
#  km_range        :numrange
#  max_cents       :integer
#  max_currency    :string
#  min_cents       :integer
#  min_currency    :string
#  rate_basis      :enum
#  rate_cents      :integer          not null
#  rate_currency   :string           not null
#  unit_range      :numrange
#  validity        :daterange        not null
#  wm_range        :numrange
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  book_routing_id :uuid             not null
#  group_id        :uuid
#
# Indexes
#
#  index_ledger_rates_on_book_routing_id  (book_routing_id)
#  index_ledger_rates_on_group_id         (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups_groups.id)
#
