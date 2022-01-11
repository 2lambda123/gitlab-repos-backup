require 'gitlab'

class App
  def initialize
    validate_env_vars!
    setup_tmp_dir!
  end

  def run
    projects.auto_paginate do |project|
      normalized_name = project.name.gsub(' ', '-')
      process_repo(project.http_url_to_repo, normalized_name)
    rescue StandardError => _e
      notifiers.each do |notifier|
        notifier.send_failed_notification(normalized_name)
      end
    end
  end

  private

  def validate_env_vars!
    throw Errors::MissingRequiredEnvVariable if project_id.empty? || private_token.empty?
    throw Errors::UndefinedCompressor if compressor.nil?
    throw Errors::UndefinedTarget if target.nil?
  end

  def projects
    Gitlab.endpoint = "https://gitlab.com/api/v4/groups/#{project_id}"
    Gitlab.private_token = private_token
    Gitlab.projects
  end

  def process_repo(repo_url, repo_name)
    clone_repo!(repo_url, repo_name)
    compressed_path = compressor.new(tmp_path, repo_name).compress
    target.new(compressed_path, repo_name).upload
  end

  def notifiers
    []
  end

  def compressor
    return if compressors.empty?

    @compressor ||= begin
                      compressors.find do |cls_name|
                        Object.const_get("Compressors::#{cls_name}").enabled?
                      end
                    end
    return if @compressor.nil?

    Object.const_get("Compressors::#{@compressor}")
  end

  def target
    return if targets.empty?

    @target ||= begin
                  targets.find do |cls_name|
                    Object.const_get("Targets::#{cls_name}").enabled?
                  end
                end
    return if @target.nil?

    Object.const_get("Targets::#{@target}")
  end

  def compressors
    @compressors ||= Compressors.constants.select { |c| Compressors.const_get(c).is_a? Class }
  end

  def targets
    @targets ||= Targets.constants.select { |c| Targets.const_get(c).is_a? Class }
  end

  def clone_repo!(url, name)
    uri = URI(url)
    uri_with_basic_auth = "#{uri.scheme}://oauth2:#{private_token}@#{uri.host}#{uri.path}"
    `git clone --mirror #{uri_with_basic_auth} #{tmp_path}/#{name}`
  end

  def tmp_path
    ENV['TMP_PATH'] || 'tmp'
  end


  def setup_tmp_dir!
    Dir.mkdir 'tmp' unless Dir.exist?('tmp')
  end

  def project_id
    @project_id ||= ENV['GITLAB_PROJECT_ID']
  end

  def private_token
    @private_token ||= ENV['GITLAB_ACCESS_TOKEN']
  end
end
