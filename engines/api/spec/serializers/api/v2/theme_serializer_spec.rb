# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ThemeSerializer do
    let(:organization_theme) { FactoryBot.create(:organizations_theme, :with_landing_pages) }
    let(:serialized_result) { described_class.new(organization_theme).serializable_hash }
    let(:target) { serialized_result.dig(:data, :attributes) }

    let(:expected_serialized_theme) do
      {
        id: organization_theme.id,
        name: organization_theme.name,
        organizationId: organization_theme.organization_id,
        emails: organization_theme.emails,
        addresses: organization_theme.addresses,
        phones: organization_theme.phones,
        landingPageVariant: organization_theme.landing_page_variant,
        emailLinks: organization_theme.email_links,
        websites: organization_theme.websites,
        whiteLogo: "",
        wideLogo: "",
        largeLogo: "",
        smallLogo: "",
        background: Rails.application.routes.url_helpers.rails_blob_url(organization_theme.background),
        landingPageHero: Rails.application.routes.url_helpers.rails_blob_url(organization_theme.landing_page_hero),
        landingPageOne: Rails.application.routes.url_helpers.rails_blob_url(organization_theme.landing_page_one),
        landingPageTwo: Rails.application.routes.url_helpers.rails_blob_url(organization_theme.landing_page_two),
        landingPageThree: Rails.application.routes.url_helpers.rails_blob_url(organization_theme.landing_page_three)
      }
    end

    it "returns the expected serialized theme" do
      expect(target).to match_array(expected_serialized_theme)
    end
  end
end
