# frozen_string_literal: true

require 'rails_helper'

module Tenants
  RSpec.describe Domain, type: :model do
    it 'is valid' do
      expect(FactoryBot.build(:tenants_domain)).to be_valid
    end
  end
end

# == Schema Information
#
# Table name: tenants_domains
#
#  id         :uuid             not null, primary key
#  default    :boolean
#  domain     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :uuid
#
# Indexes
#
#  index_tenants_domains_on_tenant_id  (tenant_id)
#
