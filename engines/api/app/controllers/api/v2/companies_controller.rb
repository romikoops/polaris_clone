# frozen_string_literal: true

module Api
  module V2
    class CompaniesController < ApiController
      include UsersUserAccess

      def create
        render json: { error_code: "duplicate_company_record" }, status: :unprocessable_entity and return if company_exists?

        company = ::Companies::Company.create!(
          name: company_params.require(:name),
          email: company_params.require(:email),
          phone: company_params[:phone],
          vat_number: company_params[:vatNumber],
          payment_terms: company_params[:paymentTerms],
          contact_person_name: company_params[:contactPersonName],
          contact_phone: company_params[:contactPhone],
          contact_email: company_params[:contactEmail],
          registration_number: company_params[:registrationNumber],
          organization: current_organization,
          address: address_from_params
        )
        render json: Api::V2::CompanySerializer.new(company), status: :created
      end

      def index
        render json: { errors: filter_params_validator.errors }, status: :unprocessable_entity and return unless filter_params_validator.valid?

        render json: Api::V2::CompanySerializer.new(
          filtered_companies.paginate(
            page: index_params[:page],
            per_page: index_params[:per_page]
          )
        )
      end

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

      def destroy
        render json: { "success": true } if company_service.destroy
      end

      private

      def company_params
        params.require(:company).permit(
          :email, :name, :paymentTerms, :phone, :vatNumber, :contactPersonName, :contactEmail, :contactPhone, :registrationNumber
        )
      end

      def address_from_params
        return nil if address_params.empty?

        address_string = %i[streetNumber street city zipCode country].reduce("") do |memo, key|
          section = address_params.dig(:address, key)
          memo + (section.presence || "")
        end
        Legacy::Address.geocoded_address(address_string)
      end

      def address_params
        params.require(:company).permit(address: %i[streetNumber street city zipCode country])
      end

      def company
        @company ||= Companies::Company.find(params[:id])
      end

      def company_exists?
        companies.find_by(name: company_params[:name]).present?
      end

      def companies
        Companies::Company.where(organization: current_organization)
      end

      def current_page
        params[:page]&.to_i || 1
      end

      def company_service
        @company_service ||= ::Companies::CompanyServices.new(company: company)
      end

      def index_params
        params.permit(:sortBy, :direction, :page, :perPage, :searchBy, :searchQuery, :beforeDate, :afterDate).transform_keys(&:underscore)
      end

      def filtered_companies
        companies = Api::Company.where(organization_id: current_organization.id)

        @filterrific = initialize_filterrific(
          companies,
          filter_params_validator.to_h
        ) || return

        companies.filterrific_find(@filterrific)
      end

      def filter_params_validator
        @filter_params_validator ||= FilterParamValidator.new(
          Api::Company::SUPPORTED_SEARCH_OPTIONS,
          Api::Company::SUPPORTED_SORT_OPTIONS,
          options: index_params.to_h
        )
      end
    end
  end
end
