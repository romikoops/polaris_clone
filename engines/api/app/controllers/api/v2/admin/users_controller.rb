# frozen_string_literal: true

module Api
  module V2
    module Admin
      class UsersController < ApiController
        include UsersUserAccess

        def index
          render json: { errors: filter_params_validator.errors }, status: :unprocessable_entity and return unless filter_params_validator.valid?

          render json: Api::V2::UserSerializer.new(
            Api::V2::UserDecorator.decorate_collection(
              filtered_users.paginate(pagination_params)
            )
          )
        end

        def create
          render json: { error_code: "duplicate_user_record" }, status: :unprocessable_entity and return if user_by_email.present?

          create_params = admin_user_attributes.merge!({ memberships_attributes: [{ role: "admin", organization_id: organization_id }] })
          new_user = Api::User.create(create_params)

          render json: new_user.errors.full_messages, status: :unprocessable_entity and return if new_user.errors.present?

          render json: Api::V2::UserSerializer.new(Api::V2::UserDecorator.new(new_user)), status: :created
        end

        def update
          render json: { error_code: "user_not_found" }, status: :unprocessable_entity and return if user_by_id.blank?

          user_by_id.update!(admin_user_attributes)
          render json: Api::V2::UserSerializer.new(
            Api::V2::UserDecorator.new(user_by_id)
          )
        end

        def destroy
          render json: { error_code: "user_not_found" }, status: :unprocessable_entity and return if user_by_id.blank?

          render json: { success: true } if user_by_id.destroy!
        end

        private

        def admin_params
          params.require(:admin).permit(:email, profile: {}, settings: %i[currency language locale]).tap { |admin_params| admin_params.require(:email) }
        end

        def profile_params
          admin_params.require(:profile).permit(:firstName, :lastName, :companyName, :phone, :externalId).tap do |profile_params|
            profile_params.require(%i[firstName lastName])
          end
        end

        def index_params
          @index_params ||= params.permit(:sortBy, :direction, :page, :perPage, :searchBy, :searchQuery, :beforeDate, :afterDate).transform_keys(&:underscore)
        end

        def pagination_params
          {
            page: [index_params[:page], 1].map(&:to_i).max,
            per_page: index_params[:per_page]
          }
        end

        def filtered_users
          @filterrific = initialize_filterrific(
            users_by_organization,
            filter_params_validator.to_h
          ) || return

          users_by_organization.filterrific_find(@filterrific)
        end

        def filter_params_validator
          @filter_params_validator ||= FilterParamValidator.new(
            Api::User::SUPPORTED_SEARCH_OPTIONS,
            Api::User::SUPPORTED_SORT_OPTIONS,
            Api::User::DEFAULT_FILTER_PARAMS,
            options: index_params.to_h
          )
        end

        def admin_user_attributes
          {}.tap do |result|
            result[:email] = admin_params[:email]
            result[:profile_attributes] = profile_params.to_h.deep_transform_keys { |key| key.underscore.to_sym }
            result[:settings_attributes] = admin_params[:settings] || {}
          end
        end

        def user_by_email
          @user_by_email ||= Api::User.find_by(email: admin_params[:email])
        end

        def user_by_id
          @user_by_id ||= Api::User.from_current_organization.find_by(id: params.require(:id))
        end

        def users_by_organization
          @users_by_organization = Api::User.from_current_organization
        end
      end
    end
  end
end
