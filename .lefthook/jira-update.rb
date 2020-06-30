#!/usr/bin/env ruby

require "bundler/inline"

gemfile do
  source "https://rubygems.org"

  gem "git"
  gem "jira-ruby", "~> 2.0"
end

require "git"
require "jira-ruby"

class JiraUpdate
  def self.run(issue_source = nil)
    new(issue_source: issue_source).run
  end

  def initialize(issue_source:)
    @issue_source = issue_source || git.current_branch
  end

  def run
    move_stale
    move_active
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
      if issue.status.name == "In Progress" && (transition = issue.transitions.find { |t| t.name == "To Do" })
        issue_transition = issue.transitions.build
        issue_transition.save!("transition" => {"id" => transition.id.to_i})
        puts "Issue #{issue.key}: #{issue.status.name} -> #{jira_client.Issue.find(issue.key).status.name}"
      end
    end
  end

  def move_active
    return unless issue_key

    issue = jira_client.Issue.find(issue_key, expand: "transitions.fields")
    return unless issue.assignee.nil? || issue.assignee.emailAddress == jira_client.options[:username]

    if issue.status.name == "To Do" && (transition = issue.transitions.find { |t| t.name == "In Progress" })
      issue_transition = issue.transitions.build
      issue_transition.save!("transition" => {"id" => transition.id.to_i})
      puts "Issue #{issue.key}: #{issue.status.name} -> #{jira_client.Issue.find(issue.key).status.name}"
    end
  end

  def issue_key
    @issue_key ||= begin
      m = issue_source.match(/(IMC-\d+)/i)
      m[1].upcase if m
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
