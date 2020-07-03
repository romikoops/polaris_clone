# frozen_string_literal: true

require 'rails_helper'

module Organizations
  RSpec.describe ThemeDecorator do
    let!(:theme) { FactoryBot.create(:organizations_theme) }

    context 'with legacy format' do
      before do
        Rails.application.routes.default_url_options[:host] = 'localhost:3000'
        theme.wide_logo.attach(io: StringIO.new, filename: 'test-image.jpg', content_type: 'image/jpg')
      end

      it 'returns a hash with the legacy keys' do
        theme_colors = described_class.new(theme).legacy_format
        aggregate_failures do
          expect(theme_colors.dig('colors', 'primary')).to eq('#F5F5F5')
          expect(theme_colors.dig('colors', 'secondary')).to eq('#F8F8F8')
          expect(theme_colors.dig('colors', 'brightPrimary')).to eq('#F6F6F6')
          expect(theme_colors.dig('colors', 'brightSecondary')).to eq('#F9F9F9')
        end
      end
    end
  end
end
