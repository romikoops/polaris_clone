# frozen_string_literal: true

require 'rails_helper'

module Tenants
  RSpec.describe ThemeDecorator do
    let!(:theme) { FactoryBot.create(:tenants_theme) }

    context 'legacy format' do
      it 'returns a hash with the legacy keys' do
        theme_colors = Tenants::ThemeDecorator.new(theme).legacy_format
        expect(theme_colors.dig('colors', 'primary')).to eq('#F5F5F5')
        expect(theme_colors.dig('colors', 'secondary')).to eq('#F8F8F8')
        expect(theme_colors.dig('colors', 'brightPrimary')).to eq('#F6F6F6')
        expect(theme_colors.dig('colors', 'brightSecondary')).to eq('#F9F9F9')
      end
    end
  end
end
