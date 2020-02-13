# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Content, type: :model do
    let(:tenant) { FactoryBot.create(:legacy_tenant) }
    let!(:content) { FactoryBot.create(:legacy_content, :with_image, component: 'WelcomeMail', section: 'subject', text: 'WELCOME_EMAIL', tenant_id: tenant.id) }

    describe '.get_component' do
      it 'returns the content broken down by section' do
        content_response = described_class.get_component('WelcomeMail', tenant.id)

        aggregate_failures do
          expect(content_response.dig('subject', 0, 'id')).to eq(content.id)
          expect(content_response.dig('subject', 0, 'section')).to eq('subject')
        end
      end
    end

    describe '.image_url' do
      it 'returns the url for the file' do
        expect(content.image_url).to include('test-image.jpg')
      end
    end

    describe 'as_content_json' do
      it 'returns the content in json form with image url' do
        content_json = content.as_content_json
        aggregate_failures do
          expect(content_json['image_url']).to include('test-image.jpg')
          expect(content_json['id']).to eq(content.id)
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: legacy_contents
#
#  id         :uuid             not null, primary key
#  component  :string
#  index      :integer
#  section    :string
#  text       :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :integer
#
# Indexes
#
#  index_legacy_contents_on_component  (component)
#  index_legacy_contents_on_tenant_id  (tenant_id)
#
