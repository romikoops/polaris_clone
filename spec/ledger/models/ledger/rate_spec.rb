# frozen_string_literal: true

require 'rails_helper'

module Ledger
  RSpec.describe Rate, type: :model do
    it 'builds a valid object' do
      expect(FactoryBot.build(:ledger_rate)).to be_valid
    end
  end
end

# == Schema Information
#
# Table name: ledger_rates
#
#  id              :uuid             not null, primary key
#  target_type     :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  location_id     :uuid
#  organization_id :uuid
#  target_id       :uuid
#  tenant_id       :uuid
#  terminal_id     :uuid
#
# Indexes
#
#  index_ledger_rates_on_location_id      (location_id)
#  index_ledger_rates_on_organization_id  (organization_id)
#  index_ledger_rates_on_tenant_id        (tenant_id)
#  index_ledger_rates_on_terminal_id      (terminal_id)
#  ledger_rate_target_index               (target_type,target_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
