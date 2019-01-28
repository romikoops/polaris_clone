# frozen_string_literal: true

class GhostEmailInterceptor
  def initialize(email:)
    @email = email
  end

  def delivering_email(message)
    message.bcc = (message.bcc || []) + [email]
  end

  private

  attr_reader :email
end
