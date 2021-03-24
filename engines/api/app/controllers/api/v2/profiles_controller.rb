# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class ProfilesController < ApiController

      def update
        ActiveRecord::Base.transaction do
          current_user.update!(email: profile_params[:email])
          profile.update!(
            first_name: profile_params[:first_name],
            last_name: profile_params[:last_name]
          )
        end
        render json: Api::V2::ProfileSerializer.new(profile)

      rescue ActiveRecord::RecordInvalid => invalid
        errors = invalid.record.errors.full_messages

        render(json: {error: errors }, status: :unprocessable_entity)
      end

      def show
        render json: Api::V2::ProfileSerializer.new(profile)
      end

      private

      def profile
        @profile ||= current_user.profile
      end

      def profile_params
        params.require(:profile).permit(:email, :first_name, :last_name)
      end
    end
  end
end
