require 'aws-sdk-s3'
require 'date'

module Targets
  class S3
    def initialize(compressed_path, repo_name)
      validate_env_vars!
      @compressed_path = compressed_path
      @repo_name = repo_name
    end

    def self.enabled?
      (ENV['TARGETS_AWS_S3_ENABLED'] || '').downcase == 'true'
    end

    def upload
      s3 = Aws::S3::Client.new
      s3.put_object(
        body: IO.read(@compressed_path),
        bucket: @bucket_name,
        key: "#{DateTime.now.year}#{DateTime.now.month}#{DateTime.now.day}/#{@repo_name}.tar.gz"
      )
    end

    private

    def validate_env_vars!
      throw Errors::MissingS3BucketName if bucket_name.nil? || bucket_name.empty?
    end

    def bucket_name
      @bucket_name ||= ENV['S3_BACKUP_BUCKET']
    end
  end
end
