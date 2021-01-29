module ApiAuth
  class ResourceHelper
    def self.resource_for_login(client:)
      return [::Users::User] if client.present? && client.name[/bridge/]

      [::Users::Client, ::Users::User]
    end
  end
end
