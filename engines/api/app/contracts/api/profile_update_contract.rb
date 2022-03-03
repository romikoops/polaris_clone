# frozen_string_literal: true

module Api
  class ProfileUpdateContract < Dry::Validation::Contract
    VALID_LANGUAGES = %w[en-GB en-US de-DE es-ES].freeze
    params do
      optional(:email).maybe(:string)
      optional(:password).maybe(:string)
      optional(:firstName).maybe(:string)
      optional(:lastName).maybe(:string)
      optional(:currency).maybe(:string)
      optional(:language).maybe(:string)
      optional(:locale).maybe(:string)
    end

    rule(:email) do
      key.failure("Invalid email") unless values[:email].blank? || values[:email].match?(URI::MailTo::EMAIL_REGEXP)
    end

    rule(:currency) do
      key.failure("Invalid currency. Refer to ISO 4217 for list of valid codes") unless values[:currency].blank? || Treasury::ExchangeRate.exists?(from: values[:currency])
    end

    rule(:language) do
      key.failure("Invalid language option. Must be one of: #{VALID_LANGUAGES.join('|')}") if values[:language] && VALID_LANGUAGES.exclude?(values[:language])
    end

    rule(:locale) do
      key.failure("Invalid locale option. Must be one of: #{VALID_LANGUAGES.join('|')}") if values[:locale] && VALID_LANGUAGES.exclude?(values[:locale])
    end

    rule(:password) do
      password = values[:password]
      if password.present?
        password_checker = StrongPassword::StrengthChecker.new(use_dictionary: false, min_word_length: 8, min_entropy: 12)
        key.failure("Password is too weak") if password_checker.is_weak?(password)
      end
    end
  end
end
