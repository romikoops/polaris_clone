# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Inserters::Notes do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:target) { FactoryBot.create(:legacy_country) }
  let(:note_data) { [country: target.code, note: "hi", contains_html: true] }
  let(:result) { described_class.new(organization: organization, data: note_data, options: {}).perform }

  describe ".perform" do
    context "with existing note" do
      let!(:note) { FactoryBot.create(:legacy_note, target: target, header: target.name, organization: organization) }

      it "finds a note record with the same header and organization and updates it with new data", :aggregate_failures do
        expect(result[:"legacy/notes"][:number_created]).to eq(0)
        note.reload
        expect(note.body).to eq(note_data.dig(0, :note))
        expect(note.contains_html).to eq(note_data.dig(0, :contains_html))
      end
    end

    context "with similar note on a different organization" do
      before { FactoryBot.create(:legacy_note, target: target, header: target.name) }

      it "finds a note record with the same header, different organization" do
        expect(result[:"legacy/notes"][:number_created]).to eq(1)
      end
    end

    context "with no matching records" do
      let(:data) { [country: target.code] }

      it "creates a new record when it does not find a record with the same header" do
        expect(result[:"legacy/notes"][:number_created]).to eq(1)
      end
    end
  end
end
