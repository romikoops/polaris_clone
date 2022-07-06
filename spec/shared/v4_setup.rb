# frozen_string_literal: true

# rubocop:disable RSpec/ContextWording
RSpec.shared_context "V4 setup" do
  # rubocop:enable RSpec/ContextWording
  let(:frame) { Rover::DataFrame.new(rows, types: types) }
  let(:types) { {} }
  let(:row) { {} }
  let(:rows) { [row] }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
  let(:state_arguments) do
    ExcelDataServices::V4::State.new(
      file: file,
      section: section_string,
      overrides: overrides
    ).tap { |tapped_state| tapped_state.frames = frames }
  end
  let(:overrides) { ExcelDataServices::V4::Overrides.new }
  let!(:file) do
    FactoryBot.create(:legacy_file).tap do |file_object|
      file_object.file.attach(io: xlsx, filename: "test-sheet.xlsx", content_type: "vnd.ms-excel")
    end
  end
  let(:xlsx) { File.open(file_fixture("excel/example_pricings.xlsx")) }
  let(:section_string) { "Pricings" }
  let(:rates_rows) { [] }
  let(:zones_rows) { [] }
  let(:fees_rows) { [] }
  let(:frames) { { "zones" => Rover::DataFrame.new(zones_rows), "rates" => Rover::DataFrame.new(rates_rows), "fees" => Rover::DataFrame.new(fees_rows), "default" => frame } }

  before do
    default_group
    Organizations.current_id = organization.id
  end
end
