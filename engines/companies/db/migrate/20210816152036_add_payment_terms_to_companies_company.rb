# frozen_string_literal: true

class AddPaymentTermsToCompaniesCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies_companies, :payment_terms, :text
  end
end
