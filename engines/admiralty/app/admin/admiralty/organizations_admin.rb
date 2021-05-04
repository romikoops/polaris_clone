# frozen_string_literal: true

Trestle.resource(:organizations, model: Admiralty::Organization) do
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
    column :live, sort: { default: true, default_order: :desc }
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |organization|
    tab :generic do
      text_field :slug
      check_box :live

      table organization.domains, admin: :domains do
        column :domain
        column :default

        actions
      end

      concat admin_link_to("New Domain", admin: :domains, action: :new, params: { domain: { organization_id: organization.id } }, class: "btn btn-success") if organization.id
    end

    tab :theme do
      fields_for :theme do
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

        row do
          col(sm: 12) do
            collection_select :blacklisted_emails, Users::Client.unscoped.where(organization_id: organization.id), :email, :email, {}, multiple: true
          end
        end
      end
    end

    tab :charge_categories do
      fields_for :charge_categories do
        row do
          col(sm: 6) { text_field :code }
          col(sm: 6) { text_field :name }
        end
      end

      concat admin_link_to("New Charge Category", admin: :charge_categories, action: :new, params: { charge_category: { organization_id: organization.id } }, class: "btn btn-success") if organization.id
    end

    tab :margins do
      fields_for :margins do
        row do
          col(sm: 3) { select :margin_type,  Pricings::Margin.margin_types.keys }
          col(sm: 3) { select :default_for,  ["rail", "ocean", "air", "truck", "local_charge", "trucking", nil] }
          col(sm: 3) { select :operator, ["+", "%"] }
          col(sm: 3) { number_field :value, label: "Value", help: "The margin value to be applied to the rates" }
        end
      end

      concat admin_link_to("New Margin", admin: :margins, action: :new, params: { margin: { organization_id: organization.id } }, class: "btn btn-success") if organization.id
    end

    tab :tenant_cargo_item_types do
      fields_for :tenant_cargo_item_types do
        row do
          col(sm: 6) { collection_select :cargo_item_type_id, Legacy::CargoItemType.all, :id, :description }
        end
      end

      concat admin_link_to("New Cargo Item Types", admin: :tenant_cargo_item_types, action: :new, params: { tenant_cargo_item_type: { organization_id: organization.id } }, class: "btn btn-success") if organization.id
    end
  end
end
