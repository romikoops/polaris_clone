# frozen_string_literal: true

FactoryBot.define do
  factory :organizations_theme, class: "Organizations::Theme" do
    organization { association(:organizations_organization, theme: instance) }

    sequence(:name) { |n| "Freight Spedetion ##{n}" }

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

    websites { {} }

    email_logo { Rack::Test::UploadedFile.new(File.expand_path("../fixtures/logo-blue.png", __dir__), "image/png") }

    trait :with_landing_pages do
      before(:create) do |theme|
        test_img = Rack::Test::UploadedFile.new(File.expand_path("../fixtures/logo-blue.png", __dir__), "image/png")
        %w[background landing_page_hero landing_page_one landing_page_two landing_page_three].each do |attribute|
          theme.send("#{attribute}=", test_img)
        end
      end
    end

    color_scheme { Organizations::DEFAULT_COLOR_SCHEMA }
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
