# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class ProfilesController < ApiController
      def update
        render json: profile_param_validator.errors.to_h, status: :unprocessable_entity and return if profile_param_validator.errors.present?

        ActiveRecord::Base.transaction do
          current_user.update!(user_update_params) unless user_update_params.empty?
          profile.update!(profile_update_params) unless profile_update_params.empty?
          settings.update!(settings_update_params) unless settings_update_params.empty?
        end
        render json: serialized_profile
      rescue ActiveRecord::RecordInvalid => e
        render(json: { error: e.record.errors.full_messages }, status: :unprocessable_entity)
      end

      def show
        render json: serialized_profile
      end

      private

      def serialized_profile
        Api::V2::ProfileSerializer.new(Api::V2::ProfileDecorator.new(profile, context: { application: doorkeeper_application }))
      end

      def profile
        @profile ||= organization_user.profile
      end

      def settings
        @settings ||= organization_user.settings
      end

      def profile_param_validator
        @profile_param_validator ||= Api::ProfileUpdateContract.new.call(profile_params.to_h)
      end

      def validated_profile_params
        @validated_profile_params ||= profile_param_validator.to_h
      end

      def profile_params
        params.require(:profile).permit(:email, :password, :firstName, :lastName, :currency, :language, :locale)
      end

      def profile_update_params
        {
          first_name: validated_profile_params[:firstName],
          last_name: validated_profile_params[:lastName]
        }.compact
      end

      def settings_update_params
        validated_profile_params.slice(:currency, :language, :locale).delete_if { |_key, value| value.blank? }
      end

      def user_update_params
        validated_profile_params.slice(:email, :password).delete_if { |_key, value| value.blank? }
      end
    end
  end
end
