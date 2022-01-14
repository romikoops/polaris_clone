# frozen_string_literal: true

class DedupeCompaniesWorker
  include Sidekiq::Worker

  def perform
    Organizations::Organization.find_each do |organization|
      Organizations.current_id = organization.id
      ActiveRecord::Base.transaction do
        dedupe_companies_for(organization: organization)
        nullify_invalid_company_emails_for(organization: organization)
      end
    end
  end

  private

  def dedupe_companies_for(organization:)
    organization_companies = Companies::Company.where(organization: organization)
    organization_companies.select(:name).distinct.pluck(:name).each do |company_name|
      duplicates = organization_companies.where("name ILIKE ?", company_name).order("external_id NULLS FIRST").to_a
      next if duplicates.length == 1

      original_company = duplicates.shift

      duplicates.each do |defunct_company|
        Companies::Membership.where(company: defunct_company).each do |defunct_membership|
          defunct_membership.update!(branch_id: defunct_company.external_id, company: original_company)
        end
        Groups::Membership.where(member: defunct_company).each do |defunct_membership|
          defunct_membership.update!(member: original_company) unless Groups::Membership.exists?(member: original_company, group: defunct_membership.group)
        end

        defunct_company.destroy!
      end

      # rubocop:disable Rails/SkipsModelValidations
      Companies::Membership.where(company: original_company).update_all(branch_id: original_company.external_id) if original_company.external_id
      Journey::Query.where(company: duplicates).update_all(company_id: original_company.id)
      Pricings::Margin.where(applicable: duplicates).update_all(applicable_id: original_company.id)
      Journey::ShipmentRequest.where(company: duplicates).update_all(company_id: original_company.id)
      organization_companies.update_all(external_id: nil)
      # rubocop:enable Rails/SkipsModelValidations
    end
  end

  def nullify_invalid_company_emails_for(organization:)
    Companies::Company.where(organization: organization).where.not(email: nil)
      .reject { |company| company.email.match?(URI::MailTo::EMAIL_REGEXP) }
      .each { |company| company.update!(email: nil) }
  end
end
