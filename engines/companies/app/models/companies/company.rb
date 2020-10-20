# frozen_string_literal: true

module Companies
  class Company < ApplicationRecord
    acts_as_paranoid
    include PgSearch::Model

    belongs_to :address, class_name: "Legacy::Address", optional: true
    belongs_to :organization, class_name: "Organizations::Organization"
    has_one :country, through: :address, class_name: "Legacy::Country"
    has_many :memberships, class_name: "Companies::Membership", dependent: :destroy

    validates :name, :external_id, uniqueness: {scope: :organization_id}

    pg_search_scope :name_search, against: %i[name], using: {
      tsearch: {prefix: true}
    }
    pg_search_scope :vat_search, against: %i[vat_number], using: {
      tsearch: {prefix: true}
    }
    pg_search_scope :address_search,
      against: %i[name],
      associated_against: {
        address: %i[geocoded_address]
      },
      using: {
        tsearch: {prefix: true}
      }
    pg_search_scope :country_search,
      against: %i[name],
      associated_against: {
        country: %i[name code]
      },
      using: {
        tsearch: {prefix: true}
      }

    scope :ordered_by, ->(col, desc = false) { reorder(col => desc.to_s == "true" ? :desc : :asc) }
  end
end

# == Schema Information
#
# Table name: companies_companies
#
#  id                 :uuid             not null, primary key
#  deleted_at         :datetime
#  email              :string
#  name               :string
#  phone              :string
#  vat_number         :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  address_id         :integer
#  external_id        :string
#  organization_id    :uuid
#  tenants_company_id :uuid
#
# Indexes
#
#  index_companies_companies_on_address_id          (address_id)
#  index_companies_companies_on_organization_id     (organization_id)
#  index_companies_companies_on_tenants_company_id  (tenants_company_id)
#
# Foreign Keys
#
#  fk_rails_...  (address_id => addresses.id)
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
