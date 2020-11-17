# frozen_string_literal: true

require "rails_helper"

module AdmiraltyTenants
  RSpec.describe OrganizationsController, type: :controller do
    routes { Engine.routes }
    render_views

    before do
      allow_any_instance_of(AdmiraltyAuth::AuthorizedController).to receive(:authenticate!).and_return(true)
    end

    let(:organizations) { FactoryBot.create_list(:organizations_organization, 5) }
    let(:max_bundle) do
      Legacy::MaxDimensionsBundle.create(mode_of_transport: "general",
                                         organization_id: organizations.sample.id,
                                         cargo_class: "lcl",
                                         aggregate: false,
                                         width: 0.59e3,
                                         length: 0.2342e3,
                                         height: 0.228e3,
                                         payload_in_kg: 0.2177e5,
                                         chargeable_weight: 0.2177e5)
    end

    describe "GET #index" do
      before do
        FactoryBot.create(:organizations_scope, target: organizations.first)
      end

      it "renders page" do
        get :index

        expect(response).to be_successful
        expect(response.body).to match(/<td>#{organizations.sample.slug}/im)
      end
    end

    describe "GET #new" do
      it "renders page" do
        get :new

        aggregate_failures do
          expect(response).to be_successful
          expect(response.body).to match(/class="new_organization"/im)
        end
      end
    end

    describe "GET #show" do
      it "renders page" do
        get :show, params: {id: organizations.first.id}

        expect(response).to be_successful
        expect(response.body).to match(/<dd.*#{organizations.first.slug}/im)
      end
    end

    describe "GET #edit" do
      before do
        FactoryBot.create(:organizations_theme, organization: organizations.first)
      end

      it "renders page" do
        get :edit, params: {id: organizations.first.id}

        expect(response).to be_successful
        expect(response.body).to match(/value="#{organizations.first.slug}"/im)
      end
    end

    describe "PATCH #update" do
      let(:organization) { organizations.first }
      let(:max_dimension_bundle) { FactoryBot.create(:legacy_max_dimensions_bundle, organization: organization) }
      let(:organization_params) { organization.attributes.slice("name", "slug").merge(scope: {foo: true}.to_json) }
      let(:updated_max_bundle) { {max_dimension_bundle.id => {width: 10}} }

      before do
        FactoryBot.create(:organizations_scope, target: organization)
      end

      it "renders page" do
        patch :update, params: {id: organization.id, organization: organization_params, max_dimensions: updated_max_bundle}

        expect(response).to redirect_to("/admiralty/organizations/#{organization.id}")
        expect(::Organizations::Organization.find(organization.id).scope.content).to eq("foo" => true)
        expect(::Legacy::MaxDimensionsBundle.find(max_dimension_bundle.id).width).to eq(10)
      end
    end

    describe "PATCH #update with invalid max dimensions" do
      before do
        FactoryBot.create(:organizations_theme, organization: organization)
      end

      let(:organization) { organizations.first }
      let(:organization_params) { organization.attributes.slice("name", "slug").merge(scope: {foo: true}.to_json) }
      let(:updated_max_bundle) { {max_bundle.id => {width: -10}} }

      it "renders page without update" do
        patch :update, params: {id: organization.id, organization: organization_params, max_dimensions: updated_max_bundle}

        expect(::Legacy::MaxDimensionsBundle.find(max_bundle.id).width).to eq(max_bundle.width)
      end
    end

    describe "POST #create" do
      let(:organization_params) do
        {
          name: "Test",
          slug: "test_organization",
          theme: {
            primary_color: "#000001",
            secondary_color: "#000002",
            bright_primary_color: "#000003",
            bright_secondary_color: "#000004",
            emails: {
              support: {
                general: "noreply@testorganization.com"
              }
            },
            phones: {
              support: "+23412345678"
            },
            addresses: {}
          },
          scope: {
            base_pricing: true
          }.to_json.to_s
        }
      end
      let(:slug) { "test_organization" }
      let(:new_organization) { ::Organizations::Organization.find_by(slug: slug) }

      before do
        FactoryBot.create(:legacy_cargo_item_type, description: "Pallet")
        stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700")
          .to_return(status: 200, body: "", headers: {})
        FactoryBot.create(:users_user, :with_profile, email: "shopadmin@itsmycargo.com")
      end

      it "renders page" do
        post :create, params: {organization: organization_params}
        expect(::Organizations::Organization.find_by(slug: slug).scope.content).to eq("base_pricing" => true)
      end

      it "creates the default admin user and auxilliary data", :aggregate_failures do
        post :create, params: {organization: organization_params.merge(slug: slug)}
        expect(Organizations::Membership.exists?(
          user: Users::User.find_by(email: "shopadmin@itsmycargo.com")
        )).to eq(true)
        expect(Legacy::MaxDimensionsBundle.exists?(organization: new_organization)).to be_truthy
        expect(Legacy::TenantCargoItemType.exists?(organization: new_organization)).to be_truthy
      end

      it "creates both shipper and agent users for the organization" do
        post :create, params: {organization: organization_params.merge(slug: slug)}
        agent = Organizations::User.unscoped.find_by(organization: new_organization, email: "agent@itsmycargo.com")
        shipper = Organizations::User.unscoped.find_by(organization: new_organization, email: "shipper@itsmycargo.com")
        aggregate_failures do
          expect(Profiles::Profile.exists?(user: agent)).to eq(true)
          expect(Profiles::Profile.exists?(user: shipper)).to eq(true)
        end
      end

      context "wiith validation errors on create" do
        before do
          FactoryBot.create(:organizations_organization, slug: organization_params[:slug])
        end

        it "fails to create Organization" do
          post :create, params: {organization: organization_params}

          aggregate_failures do
            expect(response).to be_successful
            expect(response.body).to match(/Slug has already been taken/im)
          end
        end
      end
    end
  end
end
