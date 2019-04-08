# frozen_string_literal: true

raise('Fix for duplicate headers not needed') if Railgun::Mailer::IGNORED_HEADERS.include?('reply_to')

module Railgun
  class Mailer
    silence_warnings { IGNORED_HEADERS = %w(to from subject reply_to).freeze }
  end
end

module Mailgun
  class MessageBuilder
    def reply_to(address, variables = nil)
      compiled_address = parse_address(address, variables)
      header('Reply-To', compiled_address)
    end
  end
end
