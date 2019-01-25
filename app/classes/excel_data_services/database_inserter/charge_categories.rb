# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserter
    class ChargeCategories < Base
      include ExcelDataServices::ChargeCategoryTool

      def perform
        data.each do |params|
          update_or_create_charge_category(params)
        end

        stats
      end

      private
      def update_or_create_charge_category(params)
        existing_exact_charge = ChargeCategory.find_by(
                                  tenant_id: params[:tenant_id],
                                  code: params[:fee_code],
                                  name: params[:fee_name]
                                )
        return if existing_exact_charge.present?
        existing_charge = ChargeCategory.find_by(
                            tenant_id: params[:tenant_id],
                            code: params[:fee_code]
                          )
        # TO DO - determine logic for updating fees and internal code logic
        # is_valid = validate_existing_charge(existing_charge)
        if existing_charge.present?
          existing_charge.update(name: params[:fee_name])
          add_stats(:charge_categories, existing_charge)
        else
          ChargeCategory.create!(
            tenant_id: params[:tenant_id],
            code: params[:fee_code],
            name: params[:fee_name]
          )
        end
      end

      def validate_existing_charge(charge)
        return false if charge.code.downcase == charge.name.downcase
        true
      end
    end
  end
end
