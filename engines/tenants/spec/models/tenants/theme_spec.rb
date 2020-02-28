# frozen_string_literal: true

require 'rails_helper'

module Tenants
  RSpec.describe Theme, type: :model do
    it 'creates a valid theme' do
      expect(FactoryBot.build(:tenants_theme)).to be_valid
    end
  end
end

# == Schema Information
#
# Table name: tenants_themes
#
#  id                     :uuid             not null, primary key
#  bright_primary_color   :string
#  bright_secondary_color :string
#  primary_color          :string
#  secondary_color        :string
#  welcome_text           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  tenant_id              :uuid
#
# Indexes
#
#  index_tenants_themes_on_tenant_id  (tenant_id)
#
