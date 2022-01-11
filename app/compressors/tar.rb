module Compressors
  class Tar
    def initialize(tmp_path, dir_path)
      @extension = 'tar.gz'
      @dir_path = dir_path
      @tmp_path = tmp_path
    end

    def self.enabled?
      (ENV['COMPRESSORS_TAR_ENABLED'] || '').downcase == 'true'
    end

    def compress
      `tar -czvf #{target_path} #{src_path} && rm -rf #{src_path}`
      target_path
    end

    private

    def target_path
      "#{@tmp_path}/#{@dir_path}.#{@extension}"
    end

    def src_path
      "#{@tmp_path}/#{@dir_path}"
    end
  end
end
