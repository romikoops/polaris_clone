# frozen_string_literal: true

module Companies
  class Company < ApplicationRecord
    acts_as_paranoid
    include PgSearch::Model

    before_save :set_payment_terms_to_nil, if: -> { payment_terms.blank? }
    before_validation :downcase_email, if: -> { email.present? }

    belongs_to :address, class_name: "Legacy::Address", optional: true
    belongs_to :organization, class_name: "Organizations::Organization"
    has_one :country, through: :address, class_name: "Legacy::Country"
    has_many :memberships, class_name: "Companies::Membership", dependent: :destroy
    has_many :clients, class_name: "Users::Client", through: :memberships

    validates :name, uniqueness: { scope: :organization_id, case_sensitive: false }, presence: true, allow_blank: false

    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "invalid email format" }, allow_nil: true
    validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "invalid email format" }, allow_nil: true

    pg_search_scope :name_search, against: %i[name], using: {
      tsearch: { prefix: true }
    }
    pg_search_scope :vat_search, against: %i[vat_number], using: {
      tsearch: { prefix: true }
    }
    pg_search_scope :address_search,
      against: %i[name],
      associated_against: {
        address: %i[geocoded_address]
      },
      using: {
        tsearch: { prefix: true }
      }
    pg_search_scope :country_search,
      against: %i[name],
      associated_against: {
        country: %i[name code]
      },
      using: {
        tsearch: { prefix: true }
      }

    scope :ordered_by, ->(col, desc = false) { reorder(col => desc.to_s == "true" ? :desc : :asc) }

    def set_payment_terms_to_nil
      self.payment_terms = nil
    end

    def downcase_email
      email.downcase!
    end
  end
end

# == Schema Information
#
# Table name: companies_companies
#
#  id                   :uuid             not null, primary key
#  contact_email        :string
#  contact_person_name  :string
#  contact_phone        :string
#  deleted_at           :datetime
#  email                :string
#  external_id_20220118 :string
#  name                 :citext           not null
#  payment_terms        :text
#  phone                :string
#  registration_number  :string
#  vat_number           :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  address_id           :integer
#  organization_id      :uuid
#  tenants_company_id   :uuid
#
# Indexes
#
#  index_companies_companies_on_address_id                (address_id)
#  index_companies_companies_on_organization_id           (organization_id)
#  index_companies_companies_on_organization_id_and_name  (organization_id, lower((name)::text)) UNIQUE WHERE (deleted_at IS NULL)
#  index_companies_companies_on_tenants_company_id        (tenants_company_id)
#
# Foreign Keys
#
#  fk_rails_...  (address_id => addresses.id)
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
