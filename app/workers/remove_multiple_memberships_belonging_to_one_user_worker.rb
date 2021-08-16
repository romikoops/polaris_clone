# frozen_string_literal: true

class RemoveMultipleMembershipsBelongingToOneUserWorker
  include Sidekiq::Worker
  MultipleMembershipsStillExist = Class.new(StandardError)

  def perform(*_args)
    Organizations::Organization.find_each do |org|
      default_company = Companies::Company.find_by(name: "default", organization: org)
      other_memberships = Companies::Membership.where(company: Companies::Company.where(organization: org).where.not(id: default_company.id))
      default_company.memberships.where(member_id: other_memberships.select(:member_id)).destroy_all

      dup_memberships = other_memberships.where(
        "(select count(*) from companies_memberships inr where inr.member_id = companies_memberships.member_id AND inr.deleted_at IS NULL) > 1"
      )

      dup_memberships.select("member_id").distinct.each do |company_membership|
        Companies::Membership.where(member_id: company_membership.member_id).order(created_at: :desc).drop(1).map(&:destroy!)
      end

      raise MultipleMembershipsStillExist unless dup_memberships.empty?
    end
  end
end
