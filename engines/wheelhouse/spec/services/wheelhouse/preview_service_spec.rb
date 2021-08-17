# frozen_string_literal: true

require "rails_helper"

module Wheelhouse
  RSpec.describe PreviewService, type: :service do
    ActiveJob::Base.queue_adapter = :test

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let!(:margin) { FactoryBot.create(:freight_margin, pricing: pricings.first, organization: organization, applicable: target) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:source) { FactoryBot.create(:application, name: "siren") }
    let(:preview_service) do
      described_class.new(
        creator: user,
        target: target,
        source: source,
        origin: origin_param,
        destination: destination_param,
        cargo_class: cargo_classes.first
      )
    end
    let(:load_type) { "container" }
    let(:cargo_classes) { ["fcl_20"] }
    let(:origin) do
      FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode)
    end
    let(:destination) do
      FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode)
    end
    let(:origin_param) { { hub_id: origin_hub.id } }
    let(:destination_param) { { hub_id: destination_hub.id } }
    let(:company) { FactoryBot.create(:companies_company, organization: organization) }
    let(:group) { FactoryBot.create(:groups_group, organization: organization) }
    let(:results) { preview_service.perform }
    let(:target) { user }

    before do
      Organizations.current_id = organization.id
      FactoryBot.create(:companies_membership, company: company, client: user)
      FactoryBot.create(:groups_membership, group: group, member: user)
      allow(Carta::Client).to receive(:lookup).with(id: origin.id).and_return(origin)
      allow(Carta::Client).to receive(:lookup).with(id: destination.id).and_return(destination)
      allow(Carta::Client).to receive(:suggest).with(query: origin_hub.nexus.locode).and_return(origin_hub.nexus)
      allow(Carta::Client).to receive(:suggest).with(query: destination_hub.nexus.locode).and_return(
        destination_hub.nexus
      )
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(OfferCalculator::Service::ScheduleFinder).to receive(:longest_trucking_time).and_return(10)
      # rubocop:enable RSpec/AnyInstance
    end

    include_context "complete_route_with_trucking"

    shared_examples_for "a pricing with one margin" do
      it "returns the examples for the target", :aggregate_failures do
        expect { results }.not_to(change { Journey::Query.count })
        expect(results.length).to eq(1)
        expect(results.dig(0, :freight, :fees, :bas, :margins, 0, :source_id)).to eq(margin.id)
        expect(results.dig(0, :freight, :fees, :bas, :final, :rate)).to eq(275)
      end
    end

    shared_examples_for "determining the correct client attribute from target param" do
      it "sets the target param as client attribute" do
        expect(preview_service.client).to eq(user)
      end
    end

    describe ".perform" do
      context "with user" do
        it_behaves_like "a pricing with one margin"
        it_behaves_like "determining the correct client attribute from target param"
      end

      context "with group" do
        let(:target) { group }

        it_behaves_like "a pricing with one margin"
        it_behaves_like "determining the correct client attribute from target param"
      end

      context "with company" do
        let(:target) { company }

        it_behaves_like "a pricing with one margin"
        it_behaves_like "determining the correct client attribute from target param"
      end

      context "with multiple margins" do
        let(:target) { user }
        let!(:user_margins) do
          [
            FactoryBot.create(:freight_margin, pricing: pricings.first, organization: organization, applicable: user, application_order: 2),
            FactoryBot.create(:freight_margin, pricing: pricings.first, organization: organization, applicable: user, application_order: 3)
          ]
        end

        it "returns the examples with the steps in correct order", :aggregate_failures do
          expect(results.dig(0, :freight, :fees, :bas, :margins, 1, :source_id)).to eq(user_margins.first.id)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 1, :data, "rate")).to eq(302.5)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 2, :source_id)).to eq(user_margins.last.id)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 2, :data, "rate")).to eq(332.75)
        end
      end
    end

    context "with trucking" do
      let(:origin_param) do
        {
          lat: pickup_address.latitude,
          lng: pickup_address.longitude
        }
      end
      let(:destination_param) do
        {
          lat: delivery_address.latitude,
          lng: delivery_address.longitude
        }
      end

      let!(:export_margin) do
        FactoryBot.create(:export_margin, origin_hub: origin_hub, organization: organization, applicable: user)
      end
      let!(:import_margin) do
        FactoryBot.create(:import_margin,
          destination_hub: destination_hub, organization: organization, applicable: user)
      end
      let!(:trucking_pre_margin) do
        FactoryBot.create(:trucking_pre_margin,
          destination_hub: origin_hub, organization: organization, applicable: user)
      end
      let!(:trucking_on_margin) do
        FactoryBot.create(:trucking_on_margin,
          origin_hub: destination_hub, organization: organization, applicable: user)
      end

      it_behaves_like "a pricing with one margin"

      it "generates the preview for local charges with one pricing available", :aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.dig(0, :import, :fees, :solas, :margins, 0, :source_id)).to eq(import_margin.id)
        expect(results.dig(0, :import, :fees, :solas, :final, "value")).to eq(19.25)
        expect(results.dig(0, :export, :fees, :solas, :margins, 0, :source_id)).to eq(export_margin.id)
        expect(results.dig(0, :export, :fees, :solas, :final, "value")).to eq(19.25)
      end

      it "generates the preview for pre carriage with one pricing available", :aggregate_failures do
        expect(results.dig(0, :trucking_pre, :fees, :puf, :margins, 0, :source_id)).to eq(trucking_pre_margin.id)
        expect(results.dig(0, :trucking_pre, :fees, :puf, :final, "value")).to eq(275.0)
        expect(results.dig(0, :trucking_pre, :fees, "trucking_#{cargo_classes.first}".to_sym, :margins, 0, :source_id)).to eq(trucking_pre_margin.id)
        expect(results.dig(0, :trucking_pre, :fees, "trucking_#{cargo_classes.first}".to_sym, :final, "unit", 0, "rate", "value")).to eq(110.0)
      end

      it "generates the preview for on carriage with one pricing available", :aggregate_failures do
        expect(results.dig(0, :trucking_on, :fees, :puf, :margins, 0, :source_id)).to eq(trucking_on_margin.id)
        expect(results.dig(0, :trucking_on, :fees, :puf, :final, "value")).to eq(275.0)
        expect(results.dig(0, :trucking_on, :fees, "trucking_#{cargo_classes.first}".to_sym, :margins, 0, :source_id)).to eq(trucking_on_margin.id)
        expect(results.dig(0, :trucking_on, :fees, "trucking_#{cargo_classes.first}".to_sym, :final, "unit", 0, "rate", "value")).to eq(110)
      end
    end
  end
end
