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
    belongs_to :tenant
    has_one :company, through: :address, class_name: 'Legacy::Country'

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
      ::Tenants::Group.where(id: memberships.pluck(:group_id))
    end

    def employees
      ::Tenants::User.where(company_id: id)
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
#  name        :string
#  address_id  :integer
#  vat_number  :string
#  email       :string
#  tenant_id   :uuid
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  external_id :string
#  phone       :string
#  sandbox_id  :uuid
#  deleted_at  :datetime
#
