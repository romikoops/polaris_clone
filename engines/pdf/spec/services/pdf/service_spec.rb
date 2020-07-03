# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pdf::Service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, :with_profile, organization: organization) }
  let(:load_type) { 'cargo_item' }
  let!(:shipment) {
    FactoryBot.create(:complete_legacy_shipment,
      organization: organization,
      user: user,
      load_type: load_type,
      with_breakdown: true,
      with_tenders: true)
  }
  let(:pdf_service) { described_class.new(organization: organization, user: user) }
  let(:default_args) do
    {
      shipment: shipment,
      cargo_units: shipment.cargo_units,
      quotes: pdf_service.quotes_with_trip_id(nil, [shipment])
    }
  end
  let(:quotation) { FactoryBot.create(:legacy_quotation, user: user, load_type: load_type, original_shipment: shipment) }
  let(:klass) { described_class.new(organization: organization, user: user) }

  before do
    ::Organizations.current_id = organization.id
    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png')
      .to_return(status: 200, body: '', headers: {})
    FactoryBot.create(:organizations_scope, target: organization, content: { show_chargeable_weight: true })
    FactoryBot.create(:organizations_theme, organization: organization)
  end

  context 'when it is a FCL 20 shipment' do
    let(:load_type) { 'container' }

    describe '.wheelhouse_quotation (booking shop)' do
      let(:tenders) do
        shipment.charge_breakdowns.map { |cb| { id: cb.tender_id } }
      end

      it 'generates the wheelhouse quote pdf' do
        pdf = klass.wheelhouse_quotation(shipment: shipment, tenders: tenders)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
        end
      end
    end

    describe '.admin_quotation (booking shop)' do
      it 'generates the admin quote pdf' do
        pdf = klass.admin_quotation(quotation: nil, shipment: shipment)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
        end
      end
    end

    describe '.quotation' do
      it 'generates the quote pdf' do
        pdf = klass.quotation_pdf(quotation: quotation)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
        end
      end
    end

    describe '.quotation with existing docuemnt' do
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
        pdf = klass.shipment_pdf(shipment: shipment)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
        end
      end
    end
  end

  context 'when it is a LCL shipment' do
    let(:laod_type) { 'cargo_item' }

    describe '.admin_quotation (booking shop)' do
      it 'generates the admin quote pdf' do
        pdf = klass.admin_quotation(quotation: nil, shipment: shipment)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
        end
      end
    end

    describe '.quotation' do
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
        pdf = klass.shipment_pdf(shipment: shipment)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
        end
      end
    end

    describe '.existing_document' do
      it 'returns nil when the document doesnt exist' do
        file = klass.existing_document(shipment: shipment, type: 'shipment_recap')
        aggregate_failures do
          expect(file).to be_falsy
        end
      end

      it 'returns the nil when file exists but is out of date' do
        FactoryBot.create(:legacy_file, :with_file, organization: organization, shipment: shipment, user: user, doc_type: 'shipment_recap')
        shipment.update(eori: '')
        file = klass.existing_document(shipment: shipment, type: 'shipment_recap')
        aggregate_failures do
          expect(file).to be_falsy
        end
      end

      it 'returns the file when it exists' do
        existing_file = FactoryBot.create(:legacy_file, :with_file, organization: organization, shipment: shipment, user: user, doc_type: 'shipment_recap')
        file = klass.existing_document(shipment: shipment, type: 'shipment_recap')
        aggregate_failures do
          expect(file).to eq(existing_file)
        end
      end
    end
  end

  describe '.load_type_plural' do
    context 'with multiple cargo items' do
      let(:load_type) { 'cargo_item' }

      before do
        FactoryBot.create(:legacy_cargo_item, shipment: shipment)
        FactoryBot.create(:legacy_cargo_item, shipment: shipment)
      end

      it 'returns the correct plural string' do
        expect(klass.load_type_plural(shipment: shipment)).to eq('Cargo Items')
      end
    end

    context 'with single cargo item' do
      it 'returns the correct singular string' do
        expect(klass.load_type_plural(shipment: shipment)).to eq('Cargo Item')
      end
    end

    context 'with multiple containers' do
      let(:load_type) { 'container' }

      before do
        FactoryBot.create(:legacy_container, shipment: shipment)
        FactoryBot.create(:legacy_container, shipment: shipment)
      end

      it 'returns the correct plural string' do
        expect(klass.load_type_plural(shipment: shipment)).to eq('Containers')
      end
    end

    context 'with single container' do
      let(:load_type) { 'container' }

      it 'returns the correct singular string' do
        expect(klass.load_type_plural(shipment: shipment)).to eq('Container')
      end
    end
  end

  describe '.quotes_with_trip_id' do
    let(:tender_ids) do
      [shipment.charge_breakdowns.first.tender_id]
    end

    it 'limits the quotes returned when tender ids are provided' do
      quotes = pdf_service.quotes_with_trip_id(quotation: nil, shipments: [shipment], admin: true, tender_ids: tender_ids)
      aggregate_failures do
        expect(quotes.length).to eq(1)
      end
    end
  end
end
