# frozen_string_literal: true

require 'rails_helper'

module UsersDeviseTokenAuth
  RSpec.describe UsersDeviseTokenAuth::RegistrationsController do
    describe '#quotation_tool?' do
      let(:tenant) { create(:tenant) }
      let(:user) { create(:user, tenant_id: tenant.id) }

      before do
        allow(controller).to receive(:user_signed_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'returns the quotation tool' do
        expect(controller.quotation_tool?(user)).to be(false)
      end
    end
  end
end
