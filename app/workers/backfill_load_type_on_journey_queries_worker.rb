class BackfillLoadTypeOnJourneyQueriesWorker
  include Sidekiq::Worker

  def perform
    invalid_queries = Journey::Query.where(load_type: nil)
    Organizations::Organization.where(id: invalid_queries.select(:organization_id)).find_each do |organization|
      available_load_types = organization.scope.modes_of_transport.values.uniq.map { |entry| entry.keys.reject { |load_type| entry[load_type].blank? } }
      invalid_queries.where(organization: organization).find_each do |query|
        lcl_bool = query.cargo_units.first.cargo_item? if query.cargo_units.present?
        tender_load_type = Quotations::Tender.where(id: query.results.ids).pluck(:load_type).first
        lcl_bool ||= tender_load_type == "cargo_item" unless tender_load_type.nil?
        lcl_bool ||= available_load_types.first == "cargo_item"

        query.update_column(:load_type, lcl_bool ? "lcl" : "fcl") # Neccesary to skip validations as the Cargo Ready Date validations prevents any editing
      end
    end
  end
end
