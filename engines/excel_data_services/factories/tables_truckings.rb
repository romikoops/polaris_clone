# frozen_string_literal: true

FactoryBot.define do
  factory :tables_truckings, class: "ExcelDataServices::Tables::Trucking" do
    arguments do
      organization = Factorybot.create(:organizations_organization)
      {
        applicable: FactoryBot.create(:legacy_hub, organization: organization),
        group_id: nil,
        organization_id: organization.id
      }
    end

    file { FactoryBot.create(:schema_files_trucking) }

    initialize_with do
      new(arguments: arguments, schema: file)
    end
  end
end
