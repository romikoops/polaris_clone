# frozen_string_literal: true

class BackfillInvalidCompanyUsersToDefaultWorker
  include Sidekiq::Worker

  FailedCompanyBackFill = Class.new(StandardError)
  def perform
    ActiveRecord::Base.transaction do
      companies_with_blank_name.each do |company|
        if company.external_id.present?
          assign_ext_id_as_company_name(company: company)
        else
          ::Companies::CompanyServices.new(company: company).destroy
        end
      end
      raise FailedCompanyBackFill if companies_with_blank_name.present?
    end
  end

  private

  def assign_ext_id_as_company_name(company:)
    company.name = company.external_id
    company.save!
  end

  def companies_with_blank_name
    Companies::Company.where(name: [nil, ""])
  end
end
