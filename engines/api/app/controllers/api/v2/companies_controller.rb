# frozen_string_literal: true

module Api
  module V2
    class CompaniesController < ApiController
      def show
        render json: Api::V2::CompanySerializer.new(company)
      end

      def update
        if company_params.empty?
          return render(
            json: { error: "Please provide at least one param of email, name, paymentTerms, phone, or vatNumber" },
            status: :unprocessable_entity
          )
        end

        company.update(company_params.transform_keys(&:underscore))
        render json: Api::V2::CompanySerializer.new(company)
      end

      private

      def company_params
        params.require(:company).permit(:email, :name, :paymentTerms, :phone, :vatNumber)
      end

      def company
        @company ||= Companies::Company.find(params[:id])
      end
    end
  end
end
