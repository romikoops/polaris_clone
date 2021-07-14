# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class ProfilesController < ApiController
      def update
        ActiveRecord::Base.transaction do
          current_user.update!(user_update_params) unless user_update_params.empty?
          profile.update!(profile_update_params) unless profile_update_params.empty?
        end
        render json: Api::V2::ProfileSerializer.new(profile)
      rescue ActiveRecord::RecordInvalid => e
        render(json: { error: e.record.errors.full_messages }, status: :unprocessable_entity)
      end

      def show
        render json: Api::V2::ProfileSerializer.new(profile)
      end

      private

      def profile
        @profile ||= current_user.profile
      end

      def profile_params
        params.require(:profile).permit(:email, :password, :firstName, :lastName)
      end

      def profile_update_params
        {
          first_name: profile_params[:firstName],
          last_name: profile_params[:lastName]
        }.compact
      end

      def user_update_params
        profile_params.slice(:email, :password).delete_if { |_key, value| value.blank? }
      end
    end
  end
end
