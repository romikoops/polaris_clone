# frozen_string_literal: true

module Migrator
  module Migrations
    module Companies
      class Companies < Base
        def data
          insert = <<~SQL
            WITH unique_companies as (
              SELECT DISTINCT ON (name, organization_id) name, organization_id, id
              FROM  companies_companies
            )

            INSERT INTO companies_memberships(company_id, member_type, member_id, created_at, updated_at)
            SELECT unique_companies.id, companies_memberships.member_type, companies_memberships.member_id, companies_memberships.created_at, companies_memberships.updated_at
            FROM unique_companies, companies_memberships
            JOIN companies_companies
            ON companies_companies.id = companies_memberships.company_id
            WHERE companies_companies.name = unique_companies.name
            AND companies_companies.organization_id = unique_companies.organization_id
            AND companies_companies.id != unique_companies.id
            ON conflict(member_id, company_id) do nothing
          SQL

          [insert, delete_memberships, delete_companies]
        end

        def delete_memberships
          <<~SQL
            WITH unique_companies as (
              SELECT DISTINCT ON (name, organization_id) name, organization_id, id
              FROM  companies_companies
            ), duplicated_companies as (
              SELECT id FROM companies_companies
              WHERE companies_companies.name in (select name from unique_companies)
              AND companies_companies.organization_id in (select organization_id from unique_companies)
              AND companies_companies.id not in (select id from unique_companies)
            )

            DELETE FROM companies_memberships where company_id in (select id from duplicated_companies)
          SQL
        end

        def delete_companies
          <<~SQL
            WITH unique_companies as (
              SELECT DISTINCT ON (name, organization_id) name, organization_id, id
              FROM  companies_companies
            ), duplicated_companies as (
              SELECT id FROM companies_companies
              WHERE companies_companies.name in (select name from unique_companies)
              AND companies_companies.organization_id in (select organization_id from unique_companies)
              AND companies_companies.id not in (select id from unique_companies)
            )

            DELETE FROM companies_companies where id in (select id from duplicated_companies)
          SQL
        end

        def count_required
          wrong_memberships_count = count(
            "WITH unique_companies as (
            SELECT DISTINCT ON (name, organization_id) name, organization_id, id
            FROM  companies_companies)

            SELECT COUNT(*)
            FROM unique_companies, companies_memberships
            JOIN companies_companies
            ON  companies_memberships.company_id = companies_companies.id
            WHERE companies_companies.name = unique_companies.name
            AND companies_companies.organization_id = unique_companies.organization_id
            AND companies_companies.id != unique_companies.id"
          )

          duplicated_companies_count = count(
            "WITH unique_companies as (
              SELECT DISTINCT ON (name, organization_id) name, organization_id, id
              FROM  companies_companies
            ), duplicated_companies as (
              SELECT id FROM companies_companies
              WHERE companies_companies.name in (select name from unique_companies)
              AND companies_companies.organization_id in (select organization_id from unique_companies)
              AND companies_companies.id not in (select id from unique_companies)
            )

            SELECT COUNT(*) FROM companies_companies where id in (select id from duplicated_companies)"
          )

          wrong_memberships_count * 2 + duplicated_companies_count
        end
      end
    end
  end
end
