module ApiAuth
  class ResourceHelper
    def self.resource_for_login(email:, client:)
      bridge = client.present? && client.name[/bridge/]

      return ::Authentication::User.with_membership if bridge.present?

      ::Authentication::User.authentication_scope
    end
  end
end
