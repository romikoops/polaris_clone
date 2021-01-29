class AssignCompaniesWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(*args)
    ActiveRecord::Base.connection.execute("
      INSERT INTO companies_companies (id, name, organization_id, created_at, updated_at)
      SELECT
        gen_random_uuid(), 'default', organizations_organizations.id, now(), now()
      FROM organizations_organizations
      ON CONFLICT DO NOTHING
    ")
    ActiveRecord::Base.connection.execute("
      INSERT INTO companies_memberships (
        id, member_type, member_id, company_id, created_at, updated_at
      )
      SELECT
        gen_random_uuid(), 'Users::Client', users_clients.id, companies_companies.id, now(), now()
      FROM users_clients
      JOIN organizations_organizations
        ON organizations_organizations.id = users_clients.organization_id
      JOIN companies_companies
        ON organizations_organizations.id = companies_companies.organization_id
      WHERE companies_companies.name = 'default'
      ON CONFLICT DO NOTHING
    ")
  end
end
