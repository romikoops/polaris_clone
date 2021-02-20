# frozen_string_literal: true

Trestle.resource(:organizations, model: Organizations::Organization) do
  remove_action :destroy

  menu :organizations, icon: "fa fa-building", group: :organizations

  search do |query|
    query ? collection.where("slug ILIKE ?", "%#{query}%") : collection
  end

  collection do
    model.where("slug NOT LIKE '%-sandbox'").order("live DESC", "slug")
  end

  scope :all, default: true
  scope :live, -> { model.where(live: true) }
  scope :non_live, -> { model.where(live: false) }

  # Customize the table columns shown on the index view.
  #
  table do
    column :slug, link: true
    column :live, sort: {default: true, default_order: :desc}
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |organization|
    tab :generic do
      text_field :slug
      check_box :live
    end

    tab :theme do
      fields_for :theme do
        # Form helper methods now dispatch to the product.category form scope
        text_field :name

        row do
          col(sm: 6) { text_field :primary_color }
          col(sm: 6) { text_field :secondary_color }
        end

        row do
          col(sm: 6) { text_field :bright_primary_color }
          col(sm: 6) { text_field :bright_secondary_color }
        end
      end
    end

    tab :scope do
      fields_for :scope do
        row do
          col(sm: 3) { check_box :closed_shop }
          col(sm: 3) { check_box :closed_registration }
          col(sm: 3) { check_box :open_quotation_tool }
          col(sm: 3) { check_box :closed_quotation_tool }
        end

        row do
          col(sm: 4) { select :fee_detail, %w[name key key_and_name] }
          col(sm: 3) { select :default_direction, %w[import export] }
        end

        %i[has_customs has_insurance fixed_currency dangerous_goods detailed_billing
          total_dimensions non_stackable_goods hide_user_pricing_requests
          customs_export_paper fixed_exchange_rates base_pricing require_full_address
          fine_fee_detail hide_sub_totals email_all_quotes hide_grand_total
          currency_conversion show_chargeable_weight
          condense_local_fees_pdf freight_in_original_currency show_beta_features
          show_rate_overview fixed_exchange_rate hard_trucking_limit
          hide_converted_grand_total send_email_on_quote_download cargo_overview_only
          no_aggregated_cargo offer_disclaimers closed_after_map
          feature_uploaders dedicated_pricings_only
          exclude_analytics address_fields default_total_dimensions
          append_hub_suffix expand_non_counterpart_local_charges].each_slice(4) do |slice|
          row do
            slice.each do |key|
              col(sm: 3) { check_box key }
            end
          end
        end

        row do
          col(sm: 3) { number_field :session_length }
          col(sm: 3) { number_field :search_buffer }
          col(sm: 3) { number_field :validity_period }
        end
      end
    end
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:organization).permit(:name, ...)
  # end
end
