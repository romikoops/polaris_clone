module Tenants
  class Company < ApplicationRecord
    include PgSearch
    has_many :memberships, as: :member
    has_many :groups, through: :memberships
    belongs_to :address, class_name: 'Legacy::Address', optional: true
    belongs_to :tenant

    pg_search_scope :name_search, against: %i(name), using: {
      tsearch: { prefix: true }
    }
    pg_search_scope :country_search,
    against: %i(name),
    associated_against: {
      address: {
        country: %i(name code)
      }
    },
    using: {
      tsearch: { prefix: true }
    }

    def groups
      ::Tenants::Group.where(id: memberships.pluck(:group_id))
    end

    def for_table_json(options = {})
      as_json(options).reverse_merge(
        address: address&.geocoded_address,
        country: address&.country&.name,
        employee_count: employee_count
      )
    end

    def employee_count
      ::Tenants::User.where(company_id: id).count
    end
  end
end

# == Schema Information
#
# Table name: tenants_companies
#
#  id         :uuid             not null, primary key
#  name       :string
#  address_id :integer
#  vat_number :string
#  email      :string
#  tenant_id  :uuid
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
