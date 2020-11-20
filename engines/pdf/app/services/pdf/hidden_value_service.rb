# frozen_string_literal: true

module Pdf
  class HiddenValueService
    def initialize(user:)
      @user = user
    end

    def hide_total_args
      {
        hidden_grand_total: @user.nil? || scope["hide_grand_total"],
        hidden_sub_total: @user.nil? || scope["hide_sub_totals"],
        hide_converted_grand_total: @user.nil? || scope["hide_converted_grand_total"]
      }
    end

    def admin_args
      {
        hidden_grand_total: false,
        hidden_sub_total: false,
        hide_converted_grand_total: false
      }
    end

    def scope
      @scope ||= OrganizationManager::ScopeService.new(target: @user).fetch
    end
  end
end
