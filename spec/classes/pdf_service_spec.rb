# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PdfService do
  let(:tenant) { create(:tenant, currency: 'USD') }
  let(:user) { create(:user, tenant: tenant, currency: 'USD') }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let!(:shipment) { create(:shipment, tenant: tenant, user: user, load_type: 'cargo_item') }
  let(:pdf_service) { described_class.new(tenant: tenant, user: user) }
  let(:default_args) do
    {
      shipment: shipment,
      cargo_units: shipment.cargo_units,
      quotes: pdf_service.quotes_with_trip_id(nil, [shipment])
    }
  end
  let(:klass) { described_class.new(tenant: tenant, user: user) }

  before do
    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png')
      .to_return(status: 200, body: '', headers: {})
    create(:tenants_scope, target: tenants_tenant, content: {
             show_chargeable_weight: true
           })
    %w[EUR USD].each do |currency|
      stub_request(:get, "http://data.fixer.io/latest?access_key=FAKEKEY&base=#{currency}")
        .to_return(status: 200, body: { rates: { AED: 4.11, BIF: 1.1456, EUR: 1.34 } }.to_json, headers: {})
    end
  end

  context 'when it is a FCL 20 shipment' do
    let!(:fcl_shipment) { create(:complete_legacy_shipment, tenant: tenant, user: user, load_type: 'container', with_breakdown: true) }

    describe '.admin_quotation (booking shop)' do
      it 'generates the admin quote pdf' do
        pdf = klass.admin_quotation(quotation: nil, shipment: fcl_shipment)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
        end
      end
    end

    describe '.quotation' do
      let(:quotation) { create(:legacy_quotation, user: user, load_type: 'container') }

      it 'generates the quote pdf' do
        pdf = klass.quotation_pdf(quotation: quotation)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
        end
      end
    end

    describe '.quotation with existing docuemnt' do
      let(:quotation) { create(:legacy_quotation, user: user, load_type: 'container') }

      before do
        klass.quotation_pdf(quotation: quotation)
        quotation.update(target_email: 'test@itsmycargo.com')
      end

      it 'generates the quote pdf' do
        pdf = klass.quotation_pdf(quotation: quotation)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
        end
      end
    end

    describe '.shipment_pdf' do
      it 'generates the shipment pdf' do
        pdf = klass.shipment_pdf(shipment: fcl_shipment)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
        end
      end
    end
  end

  context 'when it is a LCL shipment' do
    let(:lcl_shipment) { create(:complete_legacy_shipment, tenant: tenant, user: user, load_type: 'cargo_item', with_breakdown: true) }

    describe '.admin_quotation (booking shop)' do
      it 'generates the admin quote pdf' do
        pdf = klass.admin_quotation(quotation: nil, shipment: lcl_shipment)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
        end
      end
    end

    describe '.quotation' do
      let(:quotation) { create(:legacy_quotation, user: user) }

      it 'generates the quote pdf' do
        pdf = klass.quotation_pdf(quotation: quotation)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
        end
      end
    end

    describe '.shipment_pdf' do
      it 'generates the shipment pdf' do
        pdf = klass.shipment_pdf(shipment: lcl_shipment)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
        end
      end
    end

    describe '.existing_document' do
      it 'returns nil when the document doesnt exist' do
        file = klass.existing_document(shipment: lcl_shipment, type: 'shipment_recap')
        aggregate_failures do
          expect(file).to be_falsy
        end
      end

      it 'returns the nil when file exists but is out of date' do
        FactoryBot.create(:legacy_file, :with_file, tenant: tenant, shipment: lcl_shipment, user: user, doc_type: 'shipment_recap')
        lcl_shipment.update(eori: '')
        file = klass.existing_document(shipment: lcl_shipment, type: 'shipment_recap')
        aggregate_failures do
          expect(file).to be_falsy
        end
      end

      it 'returns the file when it exists' do
        existing_file = FactoryBot.create(:legacy_file, :with_file, tenant: tenant, shipment: lcl_shipment, user: user, doc_type: 'shipment_recap')
        file = klass.existing_document(shipment: lcl_shipment, type: 'shipment_recap')
        aggregate_failures do
          expect(file).to eq(existing_file)
        end
      end
    end
  end

  describe '.load_type_plural' do
    let(:lcl_shipment) { create(:legacy_shipment, tenant: tenant, user: user, load_type: 'cargo_item') }
    let(:fcl_shipment) { create(:legacy_shipment, tenant: tenant, user: user, load_type: 'container') }

    context 'with multiple cargo items' do
      before do
        FactoryBot.create(:legacy_cargo_item, shipment: lcl_shipment)
        FactoryBot.create(:legacy_cargo_item, shipment: lcl_shipment)
      end

      it 'returns the correct plural string' do
        expect(klass.load_type_plural(shipment: lcl_shipment)).to eq('Cargo Items')
      end
    end

    context 'with single cargo item' do
      it 'returns the correct singular string' do
        expect(klass.load_type_plural(shipment: lcl_shipment)).to eq('Cargo Item')
      end
    end

    context 'with multiple containers' do
      before do
        FactoryBot.create(:legacy_container, shipment: fcl_shipment)
        FactoryBot.create(:legacy_container, shipment: fcl_shipment)
      end

      it 'returns the correct plural string' do
        expect(klass.load_type_plural(shipment: fcl_shipment)).to eq('Containers')
      end
    end

    context 'with single container' do
      it 'returns the correct singular string' do
        expect(klass.load_type_plural(shipment: fcl_shipment)).to eq('Container')
      end
    end
  end
end
