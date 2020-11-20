# frozen_string_literal: true

class IncotermsController < ApplicationController
  skip_before_action :doorkeeper_authorize!

  def index
    buyer_seller = params[:direction] == "import" ? "buyer" : "seller"
    pre_carriage = params[:pre_carriage] != "null" ? params[:pre_carriage] : false
    on_carriage = params[:on_carriage] != "null" ? params[:on_carriage] : false
    incoterm_charge = IncotermCharge.find_by(pre_carriage: pre_carriage, on_carriage: on_carriage)
    incoterms = organization_incoterms.where("#{buyer_seller}_incoterm_charge" => incoterm_charge)
    response_handler(format_for_select_box(incoterms))
  end

  private

  def format_for_select_box(incoterms)
    incoterms.map do |incoterm|
      {label: incoterm[:description], value: incoterm, code: incoterm[:code]}
    end
  end

  def organization_incoterms
    org_incoterm_ids = OrganizationIncoterm.where(organization_id: current_organization.id).pluck(:incoterm_id)
    @organization_incoterms ||= Incoterm.where(id: org_incoterm_ids)
  end
end
