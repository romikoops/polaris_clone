module ApiAuth
  class ResourceHelper
    def self.resource_for_login(client:)
      return [::Users::User] if client.present? && client.name[/bridge/]
      return [::Users::Client] if client.present? && client.name[/siren/]

      [::Users::Client, dipper_admins]
    end

    def self.dipper_admins
      ::Users::User.joins(:memberships)
        .merge(::Users::Membership.where(organization_id: Organizations.current_id, role: :admin))
    end
  end
end
