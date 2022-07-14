# frozen_string_literal: true

module Ledger
  class Book < ApplicationRecord
    include AASM

    aasm timestamps: true do
      state :draft, initial: true
      state :published

      event :publish do
        transitions from: :draft, to: :published
      end
    end

    belongs_to :user, class_name: "Users::User"
    belongs_to :basis_book, class_name: "Ledger::Book", optional: true
    belongs_to :upload

    has_many :conflicts

    has_many :staged_book_routings
    has_many :staged_rates, through: :staged_book_routings
    has_many :staged_routings, through: :staged_book_routings, source: :routing

    has_many :merged_book_routings
    has_many :merged_rates, through: :merged_book_routings
    has_many :merged_routings, through: :merged_book_routings, source: :routing

    has_and_belongs_to_many :rates

    validates :name, uniqueness: true, presence: true
    validate :basis_book_correctness

    private

    def basis_book_correctness
      return if basis_book_id.blank?
      return if id != basis_book_id

      errors.add(:basis_book_id, "must be different with the book id")
    end
  end
end

# == Schema Information
#
# Table name: ledger_books
#
#  id            :uuid             not null, primary key
#  aasm_state    :string           default("draft")
#  name          :string           not null
#  published_at  :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  basis_book_id :uuid
#  upload_id     :uuid             not null
#  user_id       :uuid             not null
#
# Indexes
#
#  index_ledger_books_on_basis_book_id  (basis_book_id)
#  index_ledger_books_on_name           (name) UNIQUE
#  index_ledger_books_on_upload_id      (upload_id)
#  index_ledger_books_on_user_id        (user_id)
#
