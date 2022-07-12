# frozen_string_literal: true

module Api
  module V2
    module Admin
      class GroupsController < ApiController
        include UsersUserAccess

        def index
          render json: { errors: filter_params_validator.errors }, status: :unprocessable_entity and return unless filter_params_validator.valid?

          render json: Api::V2::Admin::GroupSerializer.new(filtered_groups.paginate(
            page: index_params[:page],
            per_page: index_params[:per_page]
          ))
        end

        def create
          render json: { errors: "missing_name" }, status: :bad_request and return if group_params[:name].blank?

          group = Api::Group.find_or_create_by(name: group_params[:name], organization: current_organization)
          render json: Api::V2::Admin::GroupSerializer.new(group), status: :created
        end

        def destroy
          group = Api::Group.find_by(id: params[:id])
          render json: { errors: "no_group_found" }, status: :not_found and return if group.nil?

          group.destroy
          render json: { success: true }
        end

        private

        def index_params
          params.permit(:sortBy, :direction, :page, :perPage, :searchBy, :searchQuery).transform_keys(&:underscore)
        end

        def group_params
          params.require(:group).permit(:name)
        end

        def filtered_groups
          groups = Api::Group.where(organization_id: current_organization.id)

          @filterrific = initialize_filterrific(
            groups,
            filter_params_validator.to_h
          ) || return

          groups.filterrific_find(@filterrific)
        end

        def filter_params_validator
          @filter_params_validator ||= FilterParamValidator.new(
            Api::Group::SUPPORTED_SEARCH_OPTIONS,
            Api::Group::SUPPORTED_SORT_OPTIONS,
            Api::Group::DEFAULT_FILTER_PARAMS,
            options: index_params.to_h
          )
        end
      end
    end
  end
end
