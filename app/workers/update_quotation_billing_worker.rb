class UpdateQuotationBillingWorker
  include Sidekiq::Worker

  def perform
    # Quotations with errors but not completed
    Quotations::Quotation.where.not(error_class: nil).where(completed: nil).update_all(completed: false)

    # Quotations with no tenders and erro class
    ActiveRecord::Base.connection.execute("
      UPDATE quotations_quotations
      SET completed = false
      WHERE id NOT IN (
        SELECT quotation_id FROM quotations_tenders
      )
      AND quotations_quotations.completed IS NULL
      AND quotations_quotations.error_class IS NULL")

    # Quotations with no error class and tenders
    ActiveRecord::Base.connection.execute("
      UPDATE quotations_quotations
      SET completed = true
      WHERE id IN (
          SELECT quotation_id FROM quotations_tenders
      )
      AND error_class IS NULL
      AND completed IS NULL")
  end
end
