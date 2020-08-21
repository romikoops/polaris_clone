# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::NotesController, type: :controller do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_user) }

  before do
    append_token_header
  end

  describe 'POST #upload' do
    let(:perform_request) { post :upload, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), organization_id: organization.id } }

    it_behaves_like 'uploading request async'
  end
end
