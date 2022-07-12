# frozen_string_literal: true

module Api
  module V2
    module Admin
      class GroupsMembershipsController < ApiController
        include UsersUserAccess

        before_action :validate_and_assign_members
        attr_reader :member

        def index
          render json: { errors: filter_params_validator.errors }, status: :unprocessable_entity and return unless filter_params_validator.valid?

          render json: Api::V2::Admin::GroupMembershipSerializer.new(GroupsMembershipDecorator.decorate_collection(filtered_groups_memberships.paginate(
            page: index_params[:page],
            per_page: index_params[:per_page]
          )))
        end

        def create
          render json: { error: "missing_group_id" }, status: :unprocessable_entity and return if group_membership_params[:group_id].blank?

          membership = Api::GroupsMembership.find_or_create_by(group_id: group_membership_params[:group_id], member: member)
          render json: Api::V2::Admin::GroupMembershipSerializer.new(GroupsMembershipDecorator.decorate(membership)), status: :created
        end

        def destroy
          group_membership = Api::GroupsMembership.find_by(id: params[:id])
          render json: { error: "no_membership_found" }, status: :unprocessable_entity and return if group_membership.nil?

          group_membership.destroy
          render json: { success: true }
        end

        private

        def group_membership_params
          @group_membership_params ||= params.require(:groupMembership).permit(:groupId).transform_keys(&:underscore)
        end

        def index_params
          params.permit(:sortBy, :direction, :page, :perPage, :searchBy, :searchQuery).transform_keys(&:underscore)
        end

        def groups_memberships
          # Retrive groups memberships for a company
          return Api::GroupsMembership.from_company(params[:company_id]) if params[:company_id].present?
        end

        def validate_and_assign_members
          return if params[:company_id].blank?

          company = Api::Company.find_by(id: params[:company_id])
          render json: { error: "company_not_found" }, status: :not_found and return unless company

          @member = company
        end

        def filtered_groups_memberships
          @filterrific = initialize_filterrific(
            groups_memberships,
            filter_params_validator.to_h
          ) || return

          groups_memberships.filterrific_find(@filterrific)
        end

        def filter_params_validator
          @filter_params_validator ||= FilterParamValidator.new(
            Api::GroupsMembership::SUPPORTED_SEARCH_OPTIONS,
            Api::GroupsMembership::SUPPORTED_SORT_OPTIONS,
            Api::GroupsMembership::DEFAULT_FILTER_PARAMS,
            options: index_params.to_h
          )
        end
      end
    end
  end
  end
