require "rails_helper"

module Companies
  RSpec.describe Membership, type: :model do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
    let(:company) { FactoryBot.create(:companies_company, organization: organization) }
    let!(:membership) { FactoryBot.create(:companies_membership, company: company, member: user) }

    context "with rails validations" do
      it "raises an rails validation error" do
        expect { membership.dup.save! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "without rails validations" do
      it "raises an data base validation error" do
        expect { membership.dup.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end
end
