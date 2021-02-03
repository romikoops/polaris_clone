# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pricings::Preview do
  include_context "complete_route_with_trucking"

  let(:load_type) { "cargo_item" }
  let(:cargo_classes) { ["lcl"] }
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let(:lcl_pricing) { pricings.first }
  let!(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:args) do
    {
      selectedOriginHub: origin_hub.id,
      selectedDestinationHub: destination_hub.id,
      selectedCargoClass: "lcl",
      target_id: user.id,
      target_type: "user"
    }
  end
  let(:company) do
    FactoryBot.create(:companies_company, :with_member, organization: organization, member: user)
  end
  let(:group) do
    group = FactoryBot.create(:groups_group, organization: organization)
    FactoryBot.create(:groups_membership, group: group, member: user)
    group
  end

  before do
    %w[ocean air rail truck trucking local_charge].flat_map do |mot|
      [
        FactoryBot.create(:freight_margin,
          default_for: mot, organization: organization, applicable: organization, value: 0),
        FactoryBot.create(:trucking_on_margin,
          default_for: mot, organization: organization, applicable: organization, value: 0),
        FactoryBot.create(:trucking_pre_margin,
          default_for: mot, organization: organization, applicable: organization, value: 0),
        FactoryBot.create(:import_margin,
          default_for: mot, organization: organization, applicable: organization, value: 0),
        FactoryBot.create(:export_margin,
          default_for: mot, organization: organization, applicable: organization, value: 0)
      ]
    end
    FactoryBot.create(:solas_charge, organization: organization)
    FactoryBot.create(:puf_charge, organization: organization)
  end

  describe ".perform" do
    context " with no trucking" do
      it "generates the preview for port-to-port with one pricing available" do
        user_margin = FactoryBot.create(:freight_margin,
          pricing: lcl_pricing, organization: organization, applicable: user)
        results = described_class.new(target: user, organization: organization, params: args).perform
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 0, :source_id)).to eq(user_margin.id)
          expect(results.dig(0, :freight, :fees, :bas, :final, "rate")).to eq(275)
        end
      end

      it "returns the examples for a group" do
        group_margin = FactoryBot.create(:freight_margin,
          pricing: lcl_pricing, organization: organization, applicable: group)
        results = described_class.new(target: group, organization: organization, params: args).perform

        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 0, :source_id)).to eq(group_margin.id)
          expect(results.dig(0, :freight, :fees, :bas, :final, "rate")).to eq(275)
        end
      end

      it "returns the examples for a company" do
        company_margin = FactoryBot.create(:freight_margin,
          pricing: lcl_pricing, organization: organization, applicable: company)
        results = described_class.new(target: company, organization: organization, params: args).perform

        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 0, :source_id)).to eq(company_margin.id)
          expect(results.dig(0, :freight, :fees, :bas, :final, "rate")).to eq(275)
        end
      end

      it "returns the examples for a company through the user" do
        company_margin = FactoryBot.create(:freight_margin,
          pricing: lcl_pricing, organization: organization, applicable: company)
        results = described_class.new(target: user, organization: organization, params: args).perform

        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 0, :source_id)).to eq(company_margin.id)
          expect(results.dig(0, :freight, :fees, :bas, :final, "rate")).to eq(275)
        end
      end

      it "returns the examples with the steps in correct order" do
        user_margin_1 = FactoryBot.create(:freight_margin,
          pricing: lcl_pricing, organization: organization, applicable: user, application_order: 0)
        user_margin_2 = FactoryBot.create(:freight_margin,
          pricing: lcl_pricing, organization: organization, applicable: user, application_order: 2)
        user_margin_3 = FactoryBot.create(:freight_margin,
          pricing: lcl_pricing, organization: organization, applicable: user, application_order: 3)
        results = described_class.new(target: user, organization: organization, params: args).perform

        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 0, :source_id)).to eq(user_margin_1.id)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 0, :data, "rate")).to eq(275)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 1, :source_id)).to eq(user_margin_2.id)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 1, :data, "rate")).to eq(302.5)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 2, :source_id)).to eq(user_margin_3.id)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 2, :data, "rate")).to eq(332.75)
        end
      end
    end

    context " with trucking" do
      let(:trucking_args) do
        {
          selectedCargoClass: "lcl",
          target_id: user.id,
          target_type: "user",
          selectedOriginTrucking: {
            lat: pickup_address.latitude,
            lng: pickup_address.longitude
          },
          selectedDestinationTrucking: {
            lat: delivery_address.latitude,
            lng: delivery_address.longitude
          }
        }
      end
      let!(:freight_margin) {
        FactoryBot.create(:freight_margin, pricing: lcl_pricing, organization: organization, applicable: user)
      }
      let!(:export_margin) {
        FactoryBot.create(:export_margin, origin_hub: origin_hub, organization: organization, applicable: user)
      }
      let!(:import_margin) {
        FactoryBot.create(:import_margin,
          destination_hub: destination_hub, organization: organization, applicable: user)
      }
      let!(:trucking_pre_margin) {
        FactoryBot.create(:trucking_pre_margin,
          destination_hub: origin_hub, organization: organization, applicable: user)
      }
      let!(:trucking_on_margin) {
        FactoryBot.create(:trucking_on_margin,
          origin_hub: destination_hub, organization: organization, applicable: user)
      }
      let!(:results) { described_class.new(target: user, organization: organization, params: trucking_args).perform }

      it "generates the preview for freight with one pricing available" do
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 0, :source_id)).to eq(freight_margin.id)
          expect(results.dig(0, :freight, :fees, :bas, :final, "rate")).to eq(275)
        end
      end

      it "generates the preview for local charges with one pricing available" do
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.dig(0, :import, :fees, :solas, :margins, 0, :source_id)).to eq(import_margin.id)
          expect(results.dig(0, :import, :fees, :solas, :final, "value")).to eq(19.25)
          expect(results.dig(0, :export, :fees, :solas, :margins, 0, :source_id)).to eq(export_margin.id)
          expect(results.dig(0, :export, :fees, :solas, :final, "value")).to eq(19.25)
        end
      end

      it "generates the preview for pre carriage with one pricing available" do
        aggregate_failures do
          expect(results.dig(0, :trucking_pre, :fees, :puf, :margins, 0, :source_id)).to eq(trucking_pre_margin.id)
          expect(results.dig(0, :trucking_pre, :fees, :puf, :final, "value")).to eq(275.0)
          expect(
            results.dig(0, :trucking_pre, :fees, :trucking_lcl, :margins, 0, :source_id)
          ).to eq(trucking_pre_margin.id)
          expect(results.dig(0, :trucking_pre, :fees, :trucking_lcl, :final, "unit", 0, "rate", "value")).to eq(110.0)
        end
      end

      it "generates the preview for on carriage with one pricing available" do
        aggregate_failures do
          expect(results.dig(0, :trucking_on, :fees, :puf, :margins, 0, :source_id)).to eq(trucking_on_margin.id)
          expect(results.dig(0, :trucking_on, :fees, :puf, :final, "value")).to eq(275.0)
          expect(
            results.dig(0, :trucking_on, :fees, :trucking_lcl, :margins, 0, :source_id)
          ).to eq(trucking_on_margin.id)
          expect(results.dig(0, :trucking_on, :fees, :trucking_lcl, :final, "unit", 0, "rate", "value")).to eq(110)
        end
      end
    end

    context "with dedicated_pricings_only" do
      before do
        organization.scope.update(content: {dedicated_pricings_only: true})
      end

      context "without valid rates" do
        it "returns an empty array when there are no group specific pricings" do
          results = described_class.new(target: user, organization: organization, params: args).perform
          expect(results).to be_empty
        end
      end

      context "with valid rates" do
        let(:group_lcl_pricing) do
          FactoryBot.create(:lcl_pricing,
            tenant_vehicle: tenant_vehicle,
            itinerary: itinerary,
            group_id: group.id,
            fee_attrs: {
              rate: 1000,
              rate_basis: :per_container_rate_basis,
              min: nil,
              charge_category: FactoryBot.create(:baf_charge)
            })
        end
        let!(:user_margin) {
          FactoryBot.create(:freight_margin, pricing: group_lcl_pricing, organization: organization, applicable: user)
        }

        it "returns an empty array when there are no group specific pricings" do
          results = described_class.new(target: user, organization: organization, params: args).perform
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results.dig(0, :freight, :fees, :bas, :margins, 0, :source_id)).to eq(user_margin.id)
            expect(results.dig(0, :freight, :fees, :bas, :final, "rate")).to eq(27.5)
            expect(results.dig(0, :freight, :fees, :baf, :margins, 0, :source_id)).to eq(user_margin.id)
            expect(results.dig(0, :freight, :fees, :baf, :final, "rate")).to eq(1100.0)
          end
        end
      end
    end
  end
end
