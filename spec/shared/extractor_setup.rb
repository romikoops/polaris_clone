# frozen_string_literal: true

# rubocop:disable RSpec/ContextWording
RSpec.shared_context "for excel_data_services setup" do
  # rubocop:enable RSpec/ContextWording
  let(:frame) { Rover::DataFrame.new(rows, types: types) }
  let(:row) { {} }
  let(:types) { {} }
  let(:rows) { [row] }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
  let(:state_arguments) do
    FactoryBot.build(:excel_data_services_state,
      file: file,
      section: section_string,
      overrides: overrides).tap { |tapped_state| tapped_state.frame = frame }
  end
  let(:overrides) { ExcelDataServices::V2::Overrides.new }
  let!(:file) do
    FactoryBot.create(:legacy_file).tap do |file_object|
      file_object.file.attach(io: xlsx, filename: "test-sheet.xlsx", content_type: "vnd.ms-excel")
    end
  end
  let(:xlsx) { File.open(file_fixture("excel/example_pricings.xlsx")) }
  let(:section_string) { "Pricings" }

  before do
    default_group
    Organizations.current_id = organization.id
  end
end
