Trestle.resource(:themes, model: Organizations::Theme) do
  active_storage_fields do
    %i[background small_logo large_logo email_logo white_logo wide_logo
      booking_process_image welcome_email_image]
  end

  menu do
    item :themes, icon: "fa fa-star"
  end

  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name
  #   column :created_at, align: :center
  #   actions
  # end

  # Customize the form fields shown on the new/edit views.
  #
  form do |theme|
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

    row do
      col(sm: 2) { active_storage_field :background }
      col(sm: 2) { active_storage_field :small_logo }
      col(sm: 2) { active_storage_field :large_logo }
      col(sm: 2) { active_storage_field :email_logo }
      col(sm: 2) { active_storage_field :white_logo }
      col(sm: 2) { active_storage_field :wide_logo }
      col(sm: 2) { active_storage_field :booking_process_image }
      col(sm: 2) { active_storage_field :welcome_email_image }
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
  #   params.require(:theme).permit(:name, ...)
  # end
end
