# frozen_string_literal: true
module ApiAuth
  class ResourceHelper
    def self.resource_for_login(client:)
      return [::Users::User] if client.present? && client.name[/bridge/]
      return [::Users::Client] if client.present? && client.name[/siren/]

      [
        dipper_admins,
        ::Users::Client
      ]
    end

    def self.dipper_admins
      ::Users::User.joins(:memberships)
        .merge(::Users::Membership.where(organization_id: Organizations.current_id, role: [:owner, :admin]))
    end
  end
end
