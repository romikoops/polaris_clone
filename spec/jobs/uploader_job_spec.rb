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
    context "when the current document is the newest" do
      it "performs the job successfully" do
        result = UploaderJob.perform_now(document_id: document.id, options: {user_id: user.id})
        expect(result[:has_errors]).to be true
      end
    end

    context "when the current document is not the newest" do
      before do
        FactoryBot.create(:legacy_file,
          organization: document.organization,
          created_at: document.created_at + 1.second)
      end

      it "performs the job and returns early" do
        result = UploaderJob.perform_now(document_id: document.id, options: {user_id: user.id})
        expect(result).to be_nil
      end
    end
  end
end
