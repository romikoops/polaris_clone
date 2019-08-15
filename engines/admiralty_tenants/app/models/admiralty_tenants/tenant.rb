# frozen_string_literal: true


module AdmiraltyTenants
  class Tenant < ::Tenants::Tenant
    def name
      legacy.name
    end
  end
end

# == Schema Information
#
# Table name: tenants_tenants
#
#  id         :uuid             not null, primary key
#  subdomain  :string
#  legacy_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  slug       :string
#
