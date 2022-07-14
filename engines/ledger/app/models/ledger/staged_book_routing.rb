# frozen_string_literal: true

module Ledger
  class StagedBookRouting < BookRouting
    has_many :staged_rates, class_name: :Rate, foreign_key: :book_routing_id
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
