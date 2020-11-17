# frozen_string_literal: true

FactoryBot.define do
  factory :organizations_theme, class: "Organizations::Theme" do
    association :organization, factory: :organizations_organization

    primary_color { "#F5F5F5" }
    secondary_color { "#F8F8F8" }
    bright_primary_color { "#F6F6F6" }
    bright_secondary_color { "#F9F9F9" }

    emails do
      {
        sales: {
          general: "sales.general@demo.com"
        },
        support: {
          general: "support@demo.com"
        }
      }
    end

    addresses do
      {
        main: "Brooktorkai 7, 20457 Hamburg, Germany",
        components: []
      }
    end

    phones do
      {
        main: "+46 31-85 32 00",
        support: "0173042031020"
      }
    end

    email_links { {} }

    trait :with_email_logo do
      after(:build) do |theme|
        theme.email_logo.attach(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "images", "test.jpg")),
          filename: "test.jpeg", content_type: "image/jpeg"
        )
      end
    end
  end
end

# == Schema Information
#
# Table name: organizations_themes
#
#  id                     :uuid             not null, primary key
#  bright_primary_color   :string
#  bright_secondary_color :string
#  emails                 :jsonb
#  primary_color          :string
#  secondary_color        :string
#  welcome_text           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  organization_id        :uuid
#
# Indexes
#
#  index_organizations_themes_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
