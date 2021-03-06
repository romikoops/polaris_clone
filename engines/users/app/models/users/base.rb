# frozen_string_literal: true

module Users
  class Base < ApplicationRecord
    self.abstract_class = true

    include PgSearch::Model

    pg_search_scope :search, against: %i[email], using: { tsearch: { prefix: true } }

    has_many :authentications, foreign_key: :user_id, dependent: :destroy
    accepts_nested_attributes_for :authentications

    validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }

    before_validation ->(record) { record.email&.downcase! }

    authenticates_with_sorcery!
  end
end
