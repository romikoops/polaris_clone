# frozen_string_literal: true

require "rails_helper"

module Companies
  RSpec.describe Company, type: :model do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_client, organization: organization) }
    let(:company) { FactoryBot.create(:companies_company, organization: organization) }

    it "builds a valid company" do
      expect(company).to be_valid
    end

    it "sets the payment_terms field to nil, when it is an empty string" do
      expect(FactoryBot.create(:companies_company, payment_terms: "", organization: organization).payment_terms).to be_nil
    end

    it "sets the payment_terms field to the current value provided" do
      expect(FactoryBot.create(:companies_company, payment_terms: "foo_bar", organization: organization).payment_terms).to eq("foo_bar")
    end

    it "is not valid without name" do
      expect { FactoryBot.create(:companies_company, name: nil, organization: organization) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "is not valid with invalid email format" do
      expect { FactoryBot.create(:companies_company, email: "invalid_email", organization: organization) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "is not valid with invalid contact email format" do
      expect { FactoryBot.create(:companies_company, contact_email: "invalid_email", organization: organization) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "raises an error on the DB level when an existing company with the same name uppercased, is used to try and create a company" do
      expect do
        FactoryBot.build(:companies_company, name: company.name.upcase, organization: organization).tap { |com| com.save(validate: false) }
      end.to raise_error(ActiveRecord::RecordNotUnique, /PG::UniqueViolation/)
    end

    it "raises an error when a company has no name" do
      expect { FactoryBot.create(:companies_company, name: nil, organization: organization) }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
    end

    it "raises an error when a company with the same name already exists" do
      expect { FactoryBot.create(:companies_company, name: company.name, organization: organization) }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name has already been taken")
    end

    it "raises an error when the same name from an existing company is used, even when the name is uppercased" do
      expect { FactoryBot.create(:companies_company, name: company.name.upcase, organization: organization) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "downcases the email before validating it" do
      company = FactoryBot.build(:companies_company, email: "TEST@EXAMPLE.COM", organization: organization)
      company.valid?
      expect(company.email).to eq("test@example.com")
    end
  end
end
