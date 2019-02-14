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
        correct_charge = ChargeCategory.find_or_create_by(
          tenant_id: @tenant.id,
          code: params[:fee_code].downcase,
          name: params[:fee_name]
        )
        validate_and_correct_existing_charges(correct_charge)
        add_stats(:charge_categories, correct_charge)
      end

      def validate_and_correct_existing_charges(charge)
        other_charge_category_ids = ChargeCategory.where.not(id: charge.id)
                                                  .where(
                                                    tenant_id: @tenant.id,
                                                    code: [charge.code.upcase, charge.code.downcase]
                                                  ).ids
        Charge.where(charge_category_id: other_charge_category_ids)
              .update_all(charge_category_id: charge.id)
        Charge.where(children_charge_category_id: other_charge_category_ids)
              .update_all(children_charge_category_id: charge.id)

        ChargeCategory.where(id: other_charge_category_ids).destroy_all
      end
    end
  end
end
