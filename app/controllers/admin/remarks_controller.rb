# frozen_string_literal: true

module Admin
  class RemarksController < Admin::AdminBaseController
    def create
      remark = Remark.new(remarks_params)
      remark.tenant_id = current_tenant.id

      raise ApplicationError::InvalidRemark unless remark.save

      response_handler(remark)
    end

    def index
      remarks = Remark.where(tenant_id: current_tenant.id).order(order: :asc)
      response_handler(remarks)
    end

    def update
      remark = Remark.find(params[:id])
      remark.assign_attributes(remarks_params)

      raise ApplicationError::InvalidRemark unless remark.save

      response_handler(remark)
    end

    def destroy
      remark = Remark.find(params[:id])
      raise ApplicationError::UnableToDeleteRemark unless remark.destroy!

      response_handler(remark)
    end

    def remarks_params
      params.require(:remark).permit(:id, :category, :subcategory, :body)
    end
  end
end
