Trestle.resource(:organizations, model: Organizations::Organization) do
  remove_action :destroy

  search do |query|
    query ? collection.where("slug ILIKE ?", "%#{query}%") : collection
  end

  menu do
    item :organizations, icon: "fa fa-building"
  end

  collection do
    model.where("slug NOT LIKE '%-sandbox'").order(:slug)
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :id
    column :slug, sort: {default: true, default_order: :desc}
    actions
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
        end

        %i[has_customs has_insurance fixed_currency dangerous_goods detailed_billing
          total_dimensions non_stackable_goods hide_user_pricing_requests
          customs_export_paper fixed_exchange_rates base_pricing require_full_address
          fine_fee_detail hide_sub_totals email_all_quotes hide_grand_total
          default_direction currency_conversion show_chargeable_weight
          condense_local_fees_pdf freight_in_original_currency show_beta_features
          show_rate_overview fixed_exchange_rate hard_trucking_limit
          hide_converted_grand_total send_email_on_quote_download cargo_overview_only
          no_aggregated_cargo translation_overrides offer_disclaimers closed_after_map
          feature_uploaders dedicated_pricings_only
          exclude_analytics session_length address_fields default_total_dimensions
          append_hub_suffix expand_non_counterpart_local_charges search_buffer].each_slice(4) do |slice|
          row do
            slice.each do |key|
              col(sm: 3) { check_box key }
            end
          end
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
