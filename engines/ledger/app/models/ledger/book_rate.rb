# frozen_string_literal: true

module Ledger
  class BookRate < ApplicationRecord
    belongs_to :book, class_name: "Ledger::Book"
    belongs_to :rate, class_name: "Ledger::Rate"
  end
end

# == Schema Information
#
# Table name: ledger_book_rates
#
#  book_id :uuid             not null
#  rate_id :uuid             not null
#
# Indexes
#
#  index_ledger_book_rates_on_book_id_and_rate_id  (book_id,rate_id)
#  index_ledger_book_rates_on_rate_id_and_book_id  (rate_id,book_id)
#
