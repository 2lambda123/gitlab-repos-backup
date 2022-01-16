require 'slack/incoming/webhooks'

module Notifiers
  class Slack
    def initialize(repo_name)
      validate_env_vars!
      @repo_name = repo_name
    end

    def send_failed_notification
      ::Slack::Incoming::Webhooks.new(webhook_url).post("#{@repo_name} failed backup")
    end

    def self.enabled?
      (ENV['NOTIFIERS_SLACK_ENABLED'] || '').downcase == 'true'
    end

    private

    def validate_env_vars!
      throw Errors::MissingSlackWebhookUrl if webhook_url.nil? || webhook_url.empty?
    end

    def webhook_url
      @webhook_url ||= ENV['SLACK_WEBHOOK_URL']
    end
  end
end
