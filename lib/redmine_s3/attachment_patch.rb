module RedmineS3
  module AttachmentPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        attr_accessor :s3_access_key_id, :s3_secret_acces_key, :s3_bucket, :s3_bucket
        after_validation :put_to_s3
        before_destroy   :delete_from_s3
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def put_to_s3
        if @temp_file && (@temp_file.size > 0)
          logger.debug("Uploading to #{disk_filename}")
          content = @temp_file.respond_to?(:read) ? @temp_file.read : @temp_file
          RedmineS3::Connection.put(disk_filename, content, self.content_type)
          md5 = Digest::MD5.new
          self.digest = md5.hexdigest
        end
        @temp_file = nil # so that the model's original after_save block skips writing to the fs
      end

      def delete_from_s3
        logger.debug("Deleting #{disk_filename}")
        RedmineS3::Connection.delete(disk_filename)
      end
    end
  end
end
