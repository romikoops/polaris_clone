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
        correct_charge_category = Legacy::ChargeCategory.find_or_initialize_by(
          organization_id: @organization.id,
          code: params[:fee_code].downcase
        )

        correct_charge_category.name = params[:fee_name] if correct_charge_category.name != params[:fee_name]
        add_stats(correct_charge_category, params[:row_nr])
        correct_charge_category.save!
        validate_and_correct_existing_charges(correct_charge_category)
      end

      def validate_and_correct_existing_charges(charge_category)
        other_charge_category_ids =
          Legacy::ChargeCategory.where.not(id: charge_category.id)
            .where(
              organization_id: @organization.id,
              code: [charge_category.code.upcase, charge_category.code.downcase]
            ).select(:id)
        Legacy::Charge.where(charge_category_id: other_charge_category_ids)
          .update_all(charge_category_id: charge_category.id)
        Legacy::Charge.where(children_charge_category_id: other_charge_category_ids)
          .update_all(children_charge_category_id: charge_category.id)

        Legacy::ChargeCategory.where(id: other_charge_category_ids).destroy_all
      end
    end
  end
end
