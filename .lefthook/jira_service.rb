#!/usr/bin/env ruby

require "bundler/inline"

gemfile do
  source "https://rubygems.org"

  gem "git"
  gem "jira-ruby", "~> 2.0"
end

require "git"
require "jira-ruby"

class JiraService
  def self.update_tickets(issue_source:)
    new(issue_source: issue_source).update_tickets
  end

  def self.fetch_ticket(issue_source:)
    new(issue_source: issue_source).fetch_ticket
  end

  def initialize(issue_source:)
    @issue_source = issue_source
  end

  def update_tickets
    move_stale
    move_active
  end

  def fetch_ticket
    return unless issue

    {
      key: issue.key,
      summary: issue.summary,
      assignee: issue.assignee.displayName
    }
  end

  private

  attr_reader :issue_source

  def move_stale
    # Find all In Progress tickets for current user
    jql = "assignee = \"#{jira_client.options[:username]}\""
    jql += " AND issuetype NOT IN (\"Epic\")"
    jql += " AND status IN (\"In Progress\")"
    jql += " AND key != \"#{issue_key}\"" if issue_key

    jira_client.Issue.jql(jql, expand: "transitions.fields").each do |issue|
      if issue.status.name == "In Progress" &&
          (transition = issue.transitions.find { |t| t.name == "Ready for Development" })
        issue_transition = issue.transitions.build
        issue_transition.save!("transition" => {"id" => transition.id.to_i})
        puts "Issue #{issue.key}: #{issue.status.name} -> #{jira_client.Issue.find(issue.key).status.name}"
      end
    end
  end

  def move_active
    return unless issue_key
    return unless issue.assignee.nil? || issue.assignee.emailAddress == jira_client.options[:username]

    if issue.status.name == "Ready for Development" &&
        (transition = issue.transitions.find { |t| t.name == "In Development" })
      issue_transition = issue.transitions.build
      issue_transition.save!("transition" => {"id" => transition.id.to_i})
      puts "Issue #{issue.key}: #{issue.status.name} -> #{jira_client.Issue.find(issue.key).status.name}"
    end
  end

  def issue
    return unless issue_key

    @issue ||= jira_client.Issue.find(issue_key, expand: "transitions.fields")
  end

  def issue_key
    @issue_key ||= begin
      data = case issue_source
      when :commit
        git.log(1).first.message
      when :branch
        git.current_branch
      end

      m = data.match(/(IMC[_-]\d+)/i)
      m[1].upcase.tr("_", "-") if m
    end
  end

  def git
    @git ||= Git.open(File.expand_path("..", __dir__))
  end

  def jira_client
    @jira_client ||= JIRA::Client.new(
      username: ENV.fetch("JIRA_USER") { git.config["user.email"] },
      password: ENV.fetch("JIRA_TOKEN") {
        fail(
          "Create API Token at https://id.atlassian.com/manage-profile/security/api-tokens" \
          "" \
          "Store token to environment as JIRA_TOKEN environment variable."
        )
      },
      site: ENV.fetch("JIRA_URL") { "https://itsmycargo.atlassian.net" },
      context_path: "",
      auth_type: :basic,
      http_debug: false
    )
  end
end
