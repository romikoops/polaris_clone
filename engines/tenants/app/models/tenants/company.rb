# frozen_string_literal: true

module Tenants
  class Company < ApplicationRecord
    include PgSearch::Model

    acts_as_paranoid
    has_one :scope, as: :target, class_name: 'Tenants::Scope'
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    has_many :memberships, as: :member
    has_many :users, class_name: 'Tenants::User'
    has_many :groups, through: :memberships
    belongs_to :address, class_name: 'Legacy::Address', optional: true
    belongs_to :organization, class_name: 'Organizations::Organization'
    has_one :country, through: :address, class_name: 'Legacy::Country'

    pg_search_scope :name_search, against: %i(name), using: {
      tsearch: { prefix: true }
    }
    pg_search_scope :vat_search, against: %i(vat_number), using: {
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
      ::Groups::Group.where(id: memberships.pluck(:group_id))
    end

    def employees
      ::Organizations::User.where(company_id: id)
    end

    def for_table_json(options = {})
      as_json(options).reverse_merge(
        address: address&.geocoded_address,
        country: address&.country&.name,
        employee_count: employee_count
      )
    end

    def employee_count
      employees.count
    end
  end
end

# == Schema Information
#
# Table name: tenants_companies
#
#  id          :uuid             not null, primary key
#  deleted_at  :datetime
#  email       :string
#  name        :string
#  phone       :string
#  vat_number  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  address_id  :integer
#  external_id :string
#  sandbox_id  :uuid
#  tenant_id   :uuid
#
# Indexes
#
#  index_tenants_companies_on_sandbox_id  (sandbox_id)
#  index_tenants_companies_on_tenant_id   (tenant_id)
#
