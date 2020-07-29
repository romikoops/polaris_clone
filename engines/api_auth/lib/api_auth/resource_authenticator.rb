module ApiAuth
  class ResourceAuthenticator
    def self.authenticate(resource:, email:, password:)
      password_required = OrganizationManager::ScopeService.new(
        target: nil,
        organization: Organizations::Organization.current
      ).fetch(:signup_form_fields, :password)
      return resource.authenticate(email, password) if password_required

      resource.where(organization_id: Organizations.current_id).find_by(email: email)
    end
  end
end
