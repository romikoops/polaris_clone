# frozen_string_literal: true

module Ledger
  class BookRouting < ApplicationRecord
    TYPES = %w[Ledger::StagedBookRouting Ledger::MergedBookRouting].freeze

    belongs_to :book, class_name: "Ledger::Book"
    belongs_to :routing, class_name: "Ledger::Routing"
    belongs_to :service, class_name: "Ledger::Service"

    has_many :rates, class_name: "Ledger::Rate"

    validates_enum :type
  end
end

# == Schema Information
#
# Table name: ledger_book_routings
#
#  id         :uuid             not null, primary key
#  type       :enum             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :uuid             not null
#  routing_id :uuid             not null
#  service_id :uuid             not null
#
# Indexes
#
#  index_ledger_book_routings_on_book_id     (book_id)
#  index_ledger_book_routings_on_routing_id  (routing_id)
#  index_ledger_book_routings_on_service_id  (service_id)
#
