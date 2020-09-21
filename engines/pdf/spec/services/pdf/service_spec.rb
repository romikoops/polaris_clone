# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pdf::Service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, :with_profile, organization: organization) }
  let(:trip) { FactoryBot.create(:legacy_trip, tenant_vehicle: tenant_vehicle) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier: carrier) }
  let(:carrier) { FactoryBot.create(:legacy_carrier, code: 'saco', name: 'SACO') }
  let(:load_type) { 'cargo_item' }
  let!(:shipment) do
    FactoryBot.create(:complete_legacy_shipment,
      organization: organization,
      user: user,
      trip: trip,
      load_type: load_type,
      with_breakdown: true,
      with_tenders: true,
      with_full_breakdown: true)
  end
  let(:quotations_quotation) { Quotations::Quotation.find_by(legacy_shipment_id: shipment.id) }
  let(:pdf_service) { described_class.new(organization: organization, user: user) }
  let(:default_args) do
    {
      shipment: shipment,
      cargo_units: shipment.cargo_units,
      quotes: pdf_service.quotes_with_trip_id(nil, [shipment])
    }
  end
  let(:scope_content) { { show_chargeable_weight: true } }
  let(:quotation) { FactoryBot.create(:legacy_quotation, user: user, load_type: load_type, original_shipment: shipment) }
  let(:tender_ids) do
    [shipment.charge_breakdowns.first.tender_id]
  end
  let(:klass) { described_class.new(organization: organization, user: user) }

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create(:organizations_scope, target: organization, content: scope_content)
    FactoryBot.create(:organizations_theme, organization: organization)
    shipment.charge_breakdowns.map(&:tender).each do |tender|
      Legacy::ExchangeRate.create(from: tender.amount.currency.iso_code,
                                  to: "USD", rate: 1.3,
                                  created_at: tender.created_at - 30.seconds)
    end
  end

  context 'when it is a FCL 20 shipment' do
    let(:load_type) { 'container' }

    describe '.wheelhouse_quotation (booking shop)' do
      let(:tenders) { shipment.charge_breakdowns.map(&:tender_id) }

      it 'generates the wheelhouse quote pdf' do
        pdf = klass.wheelhouse_quotation(shipment: shipment, tender_ids: tenders)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
        end
      end
    end

    describe '.admin_quotation (booking shop)' do
      it 'generates the admin quote pdf' do
        pdf_tenders = klass.tenders(shipment: shipment,
                                    quotation: quotations_quotation,
                                    tender_ids: quotations_quotation.tenders.ids,
                                    admin: false)
        pdf = klass.admin_quotation(quotation: nil, shipment: shipment, pdf_tenders: pdf_tenders)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
        end
      end

      context "with legacy quotation" do
        it "generates the admin quote pdf" do
          pdf = klass.admin_quotation(quotation: quotation, shipment: shipment, pdf_tenders: nil)
          aggregate_failures do
            expect(pdf).to be_a(Legacy::File)
            expect(pdf.file).to be_attached
          end
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
        pdf_tenders = klass.tenders(shipment: shipment,
                                    quotation: quotations_quotation,
                                    tender_ids: quotations_quotation.tenders.ids,
                                    admin: false)
        pdf = klass.admin_quotation(quotation: nil, shipment: shipment, pdf_tenders: pdf_tenders)
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
        end
      end

      context "with legacy quotation" do
        it "generates the admin quote pdf" do
          pdf = klass.admin_quotation(quotation: quotation, shipment: shipment, pdf_tenders: nil)
          aggregate_failures do
            expect(pdf).to be_a(Legacy::File)
            expect(pdf.file).to be_attached
          end
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
    context 'with default settings' do
      it 'limits the quotes returned when tender ids are provided' do
        quotes = pdf_service.quotes_with_trip_id(quotation: nil, shipments: [shipment], admin: true, tender_ids: tender_ids)
        aggregate_failures do
          expect(quotes.length).to eq(1)
          expect(quotes.dig(0, 'pre_carriage_service')).to eq('')
        end
      end
    end

    context 'with pickup carrier info settings' do
      let(:scope_content) { { voyage_info: { pre_carriage_carrier: true } } }

      it 'returns the carrier info in the correct format' do
        quotes = pdf_service.quotes_with_trip_id(quotation: nil, shipments: [shipment], admin: true, tender_ids: tender_ids)
        aggregate_failures do
          expect(quotes.length).to eq(1)
          expect(quotes.dig(0, 'pre_carriage_service')).to eq('operated by SACO')
        end
      end
    end

    context 'with pickup service info settings' do
      let(:scope_content) { { voyage_info: { pre_carriage_service: true } } }

      it 'returns the carrier info in the correct format' do
        quotes = pdf_service.quotes_with_trip_id(quotation: nil, shipments: [shipment], admin: true, tender_ids: tender_ids)
        aggregate_failures do
          expect(quotes.length).to eq(1)
          expect(quotes.dig(0, 'pre_carriage_service')).to eq('operated by standard')
        end
      end
    end

    context 'with pickup carrier and service info settings' do
      let(:scope_content) { { voyage_info: { pre_carriage_service: true, pre_carriage_carrier: true } } }

      it 'returns the carrier info in the correct format' do
        quotes = pdf_service.quotes_with_trip_id(quotation: nil, shipments: [shipment], admin: true, tender_ids: tender_ids)
        aggregate_failures do
          expect(quotes.length).to eq(1)
          expect(quotes.dig(0, 'pre_carriage_service')).to eq('operated by SACO(standard)')
        end
      end
    end
  end

  describe '.get_note_remarks' do
    context 'with notes on pricings pricings' do
      let!(:note) do
        FactoryBot.create(:legacy_note,
          organization: organization,
          remarks: true,
          pricings_pricing_id: pricing.id)
      end
      let(:tender) { Quotations::Tender.last }
      let(:pricing) do
        FactoryBot.create(:lcl_pricing,
          itinerary: tender.itinerary,
          organization: organization,
          tenant_vehicle: tenant_vehicle)
      end

      it 'returns the notes for the pricing' do
        notes = pdf_service.send(:get_note_remarks, tender_ids)
        aggregate_failures do
          expect(notes.length).to eq(1)
          expect(notes.first).to eq(note.body)
        end
      end
    end

    context 'with notes on organization (nil target)' do
      let!(:note) do
        FactoryBot.create(:legacy_note,
          organization: organization,
          remarks: true,
          target: nil,
          pricings_pricing_id: nil)
      end

      it 'returns the notes for the pricing' do
        notes = pdf_service.send(:get_note_remarks, tender_ids)
        aggregate_failures do
          expect(notes.length).to eq(1)
          expect(notes.first).to eq(note.body)
        end
      end
    end
  end
end
