# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_content, class: 'Legacy::Content' do
    component { 'main' }
    section { 'main' }
    text { 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.' }

    index { 0 }

    trait :with_image do
      after(:build) do |content|
        content.image.attach(io: StringIO.new, filename: 'test-image.jpg', content_type: 'image/jpg')
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
