# frozen_string_literal: true

require 'rails_helper'

module AdmiraltyAuth
  RSpec.describe AuthorizedController, type: :controller do
    let(:user) { FactoryBot.create(:users_user) }

    describe '.current_user' do
      context 'user does not exists' do
        context 'unsigned' do
          it 'returns nil' do
            expect(controller.current_user).to be_nil
          end
        end

        context 'signed' do
          before do
            allow_any_instance_of(described_class).to receive(:cookies).and_return(
              double('ActionDispatch::Cookies::CookieJar', signed: { admiralty_user_id: 'nonce' })
            )
          end

          it 'returns nil' do
            expect(controller.current_user).to be_nil
          end
        end
      end

      context 'user does exists' do
        context 'unsigned' do
          it 'returns nil' do
            expect(controller.current_user).to be_nil
          end
        end

        context 'signed' do
          before do
            allow_any_instance_of(described_class).to receive(:cookies).and_return(
              double('ActionDispatch::Cookies::CookieJar', signed: { admiralty_user_id: user.id })
            )
          end

          it 'returns user' do
            expect(controller.current_user).to eq(user)
          end
        end
      end
    end

    describe '.authenticate_user!' do
      controller(described_class) do
        def index
          render body: nil
        end
      end

      context 'unsigned' do
        it 'redirects' do
          get :index
          expect(response).to redirect_to('/login')
        end
      end

      context 'signed' do
        before do
          allow_any_instance_of(described_class).to receive(:current_user).and_return(user)
        end

        it 'returns nil' do
          get :index
          expect(response).to be_successful
        end
      end
    end
  end
end
