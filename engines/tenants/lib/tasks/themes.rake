# frozen_string_literal: true

namespace :tenants do
  task themes: :environment do
    ATTRIBUTES = {
      'logoWide' => 'wide_logo',
      'emailLogo' => 'email_logo',
      'logoWhite' => 'white_logo',
      'logoSmall' => 'small_logo',
      'logoLarge' => 'large_logo',
      'background' => 'background',
      'bookingProcessImage' => 'booking_process_image'
    }.freeze

    ::Tenants::Tenant.find_each do |tenant|
      next if tenant.theme.present?

      legacy_theme = tenant.legacy.theme
      colors = legacy_theme['colors']
      theme = Tenants::Theme.create!(
        tenant: tenant,
        primary_color: colors['primary'],
        secondary_color: colors['secondary'],
        bright_primary_color: colors['brightPrimary'],
        bright_secondary_color: colors['brightSecondary']
      )

      legacy_theme.except('colors', 'welcome_text').each do |key, url|
        attribute = ATTRIBUTES[key]
        next if url.blank? || attribute.blank?

        file_name = url.split('/').last
        file = URI.open(url)
        theme.send(attribute).attach(io: file, filename: file_name) if file
      end
    end
  end
end

Rake::Task['db:migrate'].enhance do
  Rake::Task['tenants:themes'].invoke
end
