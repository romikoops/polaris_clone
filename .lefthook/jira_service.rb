#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"

  gem "git"
  gem "jira-ruby", "~> 2.0"
end

require "git"
require "jira-ruby"

class JiraService
  def self.fetch_ticket
    new.fetch_ticket
  end

  def fetch_ticket
    return unless issue

    {
      key: issue.key,
      summary: issue.summary,
      assignee: issue.assignee&.displayName
    }
  end

  private

  def issue
    return unless issue_key

    @issue ||= jira_client.Issue.find(issue_key, expand: "transitions.fields")
  end

  def issue_key
    @issue_key ||= begin
      m = git.current_branch.match(/([A-Z]{2,}[_-]\d+)/i)
      m[1].upcase.tr("_", "-") if m
    end
  end

  def git
    @git ||= Git.open(File.expand_path("..", __dir__))
  end

  def jira_client
    @jira_client ||= begin
      jira_token = ENV.fetch("JIRA_TOKEN") do
        raise(
          <<~DOC
            Create API Token at https://id.atlassian.com/manage-profile/security/api-tokens

            Store token to environment as JIRA_TOKEN environment variable.
          DOC
        )
      end

      JIRA::Client.new(
        username: ENV.fetch("JIRA_USER") { git.config["user.email"] },
        password: jira_token,
        site: ENV.fetch("JIRA_URL", "https://itsmycargo.atlassian.net"),
        context_path: "",
        auth_type: :basic,
        http_debug: false
      )
    end
  end
end
