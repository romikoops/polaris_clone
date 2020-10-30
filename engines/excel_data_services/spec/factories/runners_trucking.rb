# frozen_string_literal: true

FactoryBot.define do
  factory :runners_trucking, class: "ExcelDataServices::DataFrames::Runners::Trucking" do
    arguments do
      organization = Factorybot.create(:organizations_organization)
      {
        applicable: FactoryBot.create(:legacy_hub, organization: organization),
        group_id: nil,
        organization_id: organization.id
      }.stringify_keys
    end

    file { FactoryBot.create(:schema_files_trucking) }

    initialize_with do
      new(arguments: arguments, file: file)
    end
  end
end
