require "rails_helper"

RSpec.describe UploaderJob, type: :job do
  let(:document) do
    FactoryBot.create(
      :legacy_file,
      file: Rack::Test::UploadedFile.new(
        file_fixture("dummy.xlsx"),
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      )
    )
  end
  let(:user) { FactoryBot.create(:organizations_user, organization: document.organization) }

  describe "#perform_now" do
    it "performs the job" do
      result = UploaderJob.perform_now(document_id: document.id, options: {user_id: user.id})
      expect(result[:has_errors]).to be true
    end
  end
end
