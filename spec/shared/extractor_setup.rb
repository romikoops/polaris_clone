# frozen_string_literal: true

# rubocop:disable RSpec/ContextWording
RSpec.shared_context "for excel_data_services setup" do
  # rubocop:enable RSpec/ContextWording
  let(:frame) { Rover::DataFrame.new(rows) }
  let(:rows) { [row] }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
  let(:state_arguments) do
    ExcelDataServices::V2::State.new(
      xlsx: instance_double("xlsx"),
      section: "Pricing",
      overrides: overrides
    ).tap { |tapped_state| tapped_state.frame = frame }
  end
  let(:overrides) { ExcelDataServices::V2::Overrides.new }

  before do
    default_group
    Organizations.current_id = organization.id
  end
end
