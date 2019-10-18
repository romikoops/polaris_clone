# frozen_string_literal: true

Devise.setup do |config|
  config.navigational_formats = [:json]
  config.secret_key = '287d1456b4cb804cbee7d5a539e152c677fa891ac59bd34d6899e9653448d7d81def1e41c4ab423157aa5b4aa78f945f0f43332a2e13683fbe48cf68a12e2a3c'
  config.mailer_sender = 'ItsMyCargo Accounts <accounts@itsmycargo.com>'
  config.mailer = 'AccountMailer'
  config.reconfirmable = false
  config.allow_unconfirmed_access_for = 15.days
  config.confirm_within = 60.days
end
