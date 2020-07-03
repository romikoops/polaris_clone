# frozen_string_literal: true

module Admin
  class RemarksController < Admin::AdminBaseController
    def create
      remark = Legacy::Remark.new(remarks_params.merge(sandbox: @sandbox))
      remark.organization_id = current_organization.id

      raise ApplicationError::InvalidRemark unless remark.save

      response_handler(remark)
    end

    def index
      remarks = Legacy::Remark.where(organization_id: current_organization.id, sandbox: @sandbox).order(order: :asc)
      response_handler(remarks)
    end

    def update
      remark = Legacy::Remark.find_by(id: params[:id], sandbox: @sandbox)
      remark.assign_attributes(remarks_params)

      raise ApplicationError::InvalidRemark unless remark.save

      response_handler(remark)
    end

    def destroy
      remark = Legacy::Remark.find_by(id: params[:id], sandbox: @sandbox)
      raise ApplicationError::UnableToDeleteRemark unless remark.destroy!

      response_handler(remark)
    end

    def remarks_params
      params.require(:remark).permit(:id, :category, :subcategory, :body)
    end
  end
end
