# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class ChargeCategories < ExcelDataServices::Inserters::Base
      def perform
        data.each do |params|
          update_or_create_charge_category(params)
        end

        stats
      end

      private

      def update_or_create_charge_category(params)
        correct_charge_category = ChargeCategory.find_or_initialize_by(
          tenant_id: @tenant.id,
          code: params[:fee_code].downcase,
          sandbox: @sandbox
        )
        correct_charge_category.name = params[:fee_name] if correct_charge_category.name != params[:fee_name]
        add_stats(correct_charge_category)
        correct_charge_category.save!
        validate_and_correct_existing_charges(correct_charge_category)
      end

      def validate_and_correct_existing_charges(charge_category)
        other_charge_category_ids =
          ChargeCategory.where.not(id: charge_category.id)
                        .where(
                          tenant_id: @tenant.id,
                          code: [charge_category.code.upcase, charge_category.code.downcase]
                        ).ids
        Charge.where(charge_category_id: other_charge_category_ids)
              .update_all(charge_category_id: charge_category.id)
        Charge.where(children_charge_category_id: other_charge_category_ids)
              .update_all(children_charge_category_id: charge_category.id)

        ChargeCategory.where(id: other_charge_category_ids).destroy_all
      end
    end
  end
end
