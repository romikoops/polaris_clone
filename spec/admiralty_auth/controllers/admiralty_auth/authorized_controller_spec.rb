# frozen_string_literal: true

require "rails_helper"

module AdmiraltyAuth
  RSpec.describe AuthorizedController, type: :controller do
    let(:user) { FactoryBot.create(:users_user) }

    describe ".authenticated?" do
      context "when unsigned" do
        it "returns nil" do
          expect(controller.authenticated?).to be false
        end
      end

      context "when signed" do
        before do
          session[:last_activity_at] = Time.zone.now
        end

        it "returns user" do
          expect(controller.authenticated?).to be true
        end
      end
    end

    describe ".authenticate!" do
      controller(described_class) do
        def index
          render body: nil
        end
      end

      context "when unsigned" do
        it "redirects" do
          get :index
          expect(response).to redirect_to("/admiralty/login")
        end
      end

      context "when signed" do
        before do
          allow_any_instance_of(described_class).to receive(:authenticated?).and_return(true)
        end

        it "returns nil" do
          get :index
          expect(response).to be_successful
        end
      end
    end
  end
end
