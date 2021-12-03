# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe ApiController, type: :controller do
    routes { Engine.routes }

    subject(:controller) { described_class.new }

    let!(:organization) { FactoryBot.create(:organizations_organization) }
    let(:domain) { organization.domains.first }

    before do
      allow(controller).to receive(:request).and_return(request)
    end

    describe "#current_organization" do
      context "when it should find an organization" do
        shared_examples_for "a detected organization" do
          it "finds the organization" do
            expect(controller.current_organization).to eq(organization)
          end
        end

        before do
          request.headers["HTTP_REFERER"] = "http://#{domain.domain}"
        end

        context "when organization_id is in RequestStore" do
          before do
            RequestStore.store[:organization_id] = organization.id
          end

          it_behaves_like "a detected organization"
        end

        context "when organization_id is in params" do
          before do
            request.params[:organization_id] = organization.id
          end

          it_behaves_like "a detected organization"
        end

        context "when organization_id is not in params" do
          context "when organization_domain is present" do
            context "when Rails environment is not 'development'" do
              context "when referrer_host matches domain exactly" do
                it_behaves_like "a detected organization"
              end

              context "when referrer_host matches an ILIKE pattern" do
                before do
                  FactoryBot.create(:organizations_domain, domain: "%.itsmycargo.test", organization: organization, default: false)
                  request.headers["HTTP_REFERER"] = "http://other.itsmycargo.test"
                end

                it_behaves_like "a detected organization"
              end
            end

            context "when domain wasn't matched by referrer_host and Rails environment is 'development'" do
              let(:rails_env) { instance_double("Rails environment", "development?": true) }

              before do
                allow(Organizations::Domain).to receive(:find_by).twice
                allow(Rails).to receive(:env).and_return(rails_env)
                allow(Organizations::Domain).to receive(:find_by).with(domain: "demo.local").and_return(domain)
              end

              it_behaves_like "a detected organization"
            end
          end

          context "when organization_slug is present" do
            before do
              allow(controller).to receive(:organization_domain).and_return(nil)
            end

            it_behaves_like "a detected organization"
          end
        end
      end

      describe "when it should not find an organization" do
        it "does not find the organization" do
          expect(controller.current_organization).to be_nil
        end
      end
    end

    describe "#validate_referrer!" do
      controller do
        skip_before_action :doorkeeper_authorize!
        skip_before_action :ensure_organization!
        before_action :validate_referrer!, only: [:create]
        def create
          render json: { success: true }
        end
      end

      shared_examples_for "a valid referrer" do
        it "returns a 200 OK response" do
          expect(response).to have_http_status(:ok)
        end
      end

      shared_examples_for "an invalid referrer" do
        it "returns a 401 unauthorized response" do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when referer is a valid organization domain" do
        before do
          request.headers["Referer"] = "http://#{domain.domain}"
          post :create, as: :json
        end

        it_behaves_like "a valid referrer"
      end

      context "when referer is not organization domain, but a valid imc domain" do
        before do
          request.headers["Referer"] = "http://bridge.itsmycargo.com"
          post :create, as: :json
        end

        it_behaves_like "a valid referrer"
      end

      context "when referer is not organization domain, but a valid wildcard imc domain" do
        before do
          request.headers["Referer"] = "http://siren-sir-1337.itsmycargo.dev"
          post :create, as: :json
        end

        it_behaves_like "a valid referrer"
      end

      context "when referer has a trailing slash" do
        before do
          request.headers["Referer"] = "http://siren-sir-1337.itsmycargo.dev/"
          post :create, as: :json
        end

        it_behaves_like "a valid referrer"
      end

      context "when referer is a full url" do
        before do
          request.headers["Referer"] = "https://siren.itsmycargo.shop/en-US/quotations/quote/ab54db86-9008-4560-9601-bf30fe6bef86/results"
          post :create, as: :json
        end

        it_behaves_like "a valid referrer"
      end

      context "when referer is not organization domain, nor a valid imc domain" do
        before do
          request.headers["Referer"] = "http://foobar.example"
          post :create, as: :json
        end

        it_behaves_like "an invalid referrer"
      end

      context "when referer does not have a subdomain" do
        before do
          request.headers["Referer"] = "http://itsmycargo.com"
          post :create, as: :json
        end

        it_behaves_like "an invalid referrer"
      end

      context "when referer has multiple TLDs" do
        before do
          request.headers["Referer"] = "http://bridge.itsmycargo.com.dev"
          post :create, as: :json
        end

        it_behaves_like "an invalid referrer"
      end

      context "when referer has an unsupported subdomain" do
        before do
          request.headers["Referer"] = "http://different.itsmycargo.com"
          post :create, as: :json
        end

        it_behaves_like "an invalid referrer"
      end
    end
  end
end
