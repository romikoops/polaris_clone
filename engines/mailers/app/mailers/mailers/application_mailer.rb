# frozen_string_literal: true

module Mailers
  class ApplicationMailer < ActionMailer::Base
    default from: 'no-reply@itsmycargo.com'
    layout 'mailers/mailer'
  end
end
