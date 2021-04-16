# frozen_string_literal: true

if Rails.env.development? || Rails.env.test?
  namespace :saml do
    desc "Initialize SAML for given organization"
    task :init, [:slug] => :environment do |_, args|
      organization = Organizations::Organization.find_by!(slug: args.slug)
      metadata = Net::HTTP.get(URI("http://localhost:4567/saml/metadata"))

      saml = Organizations::SamlMetadatum.find_or_initialize_by(organization_id: organization.id)
      saml.update(content: metadata)
    end
  end
end
