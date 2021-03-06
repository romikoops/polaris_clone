# frozen_string_literal: true

module Api
  module V2
    module Admin
      class CompaniesController < ApiController
        include UsersUserAccess

        def create
          render json: { error_code: "duplicate_company_record" }, status: :unprocessable_entity and return if company_exists?

          company = ::Api::Company.create!(
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
          if update_params.empty?
            return render(
              json: { error: "Please provide at least one param of email, name, paymentTerms, phone, or vatNumber" },
              status: :unprocessable_entity
            )
          end

          company.update(update_params)
          render json: Api::V2::CompanySerializer.new(company)
        end

        def destroy
          render json: { success: true } if company_service.destroy
        end

        private

        def company_params
          params.require(:company).permit(
            :email, :name, :paymentTerms, :phone, :vatNumber, :contactPersonName, :contactEmail, :contactPhone, :registrationNumber
          )
        end

        def update_params
          {}.tap do |param|
            param.merge!(company_params.transform_keys(&:underscore))
            param.merge!(address: address_from_params) unless address_params.empty?
          end
        end

        def address_from_params
          return nil if address_params.empty?

          address_string = %i[street streetNumber city zipCode].reduce("") do |memo, key|
            section = address_params.dig(:address, key)
            memo + (section.present? ? "#{section}, " : "")
          end
          Legacy::Address.geocoded_address(address_string).tap { |address| address.country_id = address_params.dig(:address, "countryId") }
        end

        def address_params
          params.require(:company).permit(address: %i[streetNumber street city zipCode countryId])
        end

        def company
          @company ||= Api::Company.find(params[:id])
        end

        def company_exists?
          companies.find_by(name: company_params[:name]).present?
        end

        def companies
          Api::Company.where(organization: current_organization)
        end

        def company_service
          @company_service ||= ::Companies::CompanyServices.new(company: company)
        end

        def index_params
          params.permit(:sortBy, :direction, :page, :perPage, :searchBy, :searchQuery, :beforeDate, :afterDate).transform_keys(&:underscore)
        end

        def filtered_companies
          companies = Api::Company.includes(:address, :country).where(organization_id: current_organization.id)

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
            Api::Company::DEFAULT_FILTER_PARAMS,
            options: index_params.to_h
          )
        end
      end
    end
  end
end
