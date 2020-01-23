# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PdfService do
  let(:tenant) { create(:tenant, currency: 'USD') }
  let(:user) { create(:user, tenant: tenant, currency: 'USD') }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let!(:shipment) { create(:shipment, tenant: tenant, user: user, load_type: 'cargo_item') }
  let!(:agg_shipment) { create(:shipment, tenant: tenant, user: user, load_type: 'cargo_item', with_aggregated_cargo: true) }
  let(:pdf_service) { PdfService.new(tenant: tenant, user: user) }
  let(:default_args) do
    {
      shipment: shipment,
      cargo_units: shipment.cargo_units,
      quotes: pdf_service.quotes_with_trip_id(nil, [shipment])
    }
  end
  let(:klass) { described_class.new(tenant: tenant, user: user) }
  before do
    stub_request(:get, "https://assets.itsmycargo.com/assets/logos/logo_box.png")
       .to_return(status: 200, body: "", headers: {})
    create(:tenants_scope, target: tenants_tenant, content: {
             show_chargeable_weight: true
           })
  end

  context 'FCL 20 shipment' do
    let!(:fcl_shipment) { create(:complete_legacy_shipment, tenant: tenant, user: user, load_type: 'container', with_breakdown: true) }
    describe '.admin_quotation (booking shop)' do


      it 'generates the admin quote pdf' do
        pdf = klass.admin_quotation(quotation: nil, shipment: fcl_shipment)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::Document)
          expect(pdf.file.attached?).to be_truthy
        end
      end
    end

    describe '.quotation' do
      let(:quotation) { create(:quotation, user: user, load_type: 'container') }

      it 'generates the quote pdf' do
        pdf = klass.quotation_pdf(quotation: quotation)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::Document)
          expect(pdf.file.attached?).to be_truthy
        end
      end
    end

    describe '.shipment_pdf' do
      it 'generates the shipment pdf' do
        pdf = klass.shipment_pdf(shipment: fcl_shipment)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::Document)
          expect(pdf.file.attached?).to be_truthy
        end
      end
    end
  end

  context 'LCL shipment' do
    let!(:lcl_shipment) { create(:complete_legacy_shipment, tenant: tenant, user: user, load_type: 'cargo_item', with_breakdown: true) }
    describe '.admin_quotation (booking shop)' do

      it 'generates the admin quote pdf' do
        pdf = klass.admin_quotation(quotation: nil, shipment: lcl_shipment)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::Document)
          expect(pdf.file.attached?).to be_truthy
        end
      end
    end

    describe '.quotation' do
      let(:quotation) { create(:quotation, user: user) }

      it 'generates the quote pdf' do
        pdf = klass.quotation_pdf(quotation: quotation)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::Document)
          expect(pdf.file.attached?).to be_truthy
        end
      end
    end

    describe '.shipment_pdf' do
      it 'generates the shipment pdf' do
        pdf = klass.shipment_pdf(shipment: lcl_shipment)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::Document)
          expect(pdf.file.attached?).to be_truthy
        end
      end
    end
  end
end
