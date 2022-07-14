# frozen_string_literal: true

module Ledger
  class CurrentBook < ApplicationRecord
    belongs_to :organization, class_name: "Organizations::Organization"
    belongs_to :user, class_name: "Users::User"
    belongs_to :book, class_name: "Ledger::Book"
  end
end

# == Schema Information
#
# Table name: ledger_current_books
#
#  id              :uuid             not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  book_id         :uuid             not null
#  organization_id :uuid             not null
#  user_id         :uuid             not null
#
# Indexes
#
#  index_ledger_current_books_on_book_id          (book_id)
#  index_ledger_current_books_on_organization_id  (organization_id)
#  index_ledger_current_books_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (user_id => users_users.id)
#
