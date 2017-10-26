class PdfsController < ApplicationController
  before_action :require_login_and_correct_id

  def bill_of_lading
    shipment = current_user.shipments.find(params[:shipment_id])

    if shipment
      render(pdf: "Bill_of_lading_copy_#{shipment.imc_reference}", layout: 'pdfs/simple.pdf', template: 'shipments/pdfs/bill_of_lading.pdf', locals: { shipment: shipment }, show_as_html: params.key?('debug'), :margin => {:top=> 5, :bottom => 5, :left=> 5, :right => 5})
    end
  end

  private

  def require_login_and_correct_id
    unless user_signed_in? && current_user.id.to_s == params[:user_id]
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end