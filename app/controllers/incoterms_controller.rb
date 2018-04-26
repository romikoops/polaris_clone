class IncotermsController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!
  def index
    buyer_seller = params[:direction] == 'import' ? 'buyer' : 'seller'
    pre_carriage = params[:pre_carriage]
    on_carriage = params[:on_carriage]
    mot = params[:mode_of_transport]
    incoterm_charge = IncotermCharge.find_by(pre_carriage: pre_carriage, on_carriage: on_carriage)
    incoterms = current_user.tenant.incoterms.where("#{buyer_seller}_incoterm_charge" => incoterm_charge)
    awesome_print incoterms
    response_handler(format_for_select_box(incoterms))
  end

  private

  def format_for_select_box(incoterms)
		incoterms.map do |incoterm| 
			{ label: incoterm[:description], value: incoterm, code:incoterm[:code] }
		end		
	end
end
