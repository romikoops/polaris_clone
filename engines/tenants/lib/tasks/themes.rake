# frozen_string_literal: true

namespace :tenants do
  task themes: :environment do
    ::Tenants::Tenant.find_each do |tenant|
      next if tenant.theme.present?

      legacy_theme = tenant.legacy.theme
      theme = Tenants::Theme.create!(
        tenant: tenant,
        primary_color: legacy_theme['colors']['primary'],
        secondary_color: legacy_theme['colors']['secondary'],
        bright_primary_color: legacy_theme['colors']['brightPrimary'],
        bright_secondary_color: legacy_theme['colors']['brightSecondary']
      )
      legacy_theme.except('colors', 'welcome_text').each do |key, url|
        next if url.blank?

        file_name = url.split('/').last
        attribute = {
          'logoWide' => 'wide_logo',
          'emailLogo' => 'email_logo',
          'logoWhite' => 'white_logo',
          'logoSmall' => 'small_logo',
          'logoLarge' => 'large_logo',
          'background' => 'background',
          'bookingProcessImage' => 'booking_process_image'
        }[key]
        file = URI.open(url)
        theme.send(attribute).attach(io: file, filename: file_name) if file
      end
    end
  end
end

Rake::Task['db:migrate'].enhance do
  Rake::Task['tenants:themes'].invoke
end
