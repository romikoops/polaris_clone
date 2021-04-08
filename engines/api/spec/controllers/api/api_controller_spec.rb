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
  end
end
