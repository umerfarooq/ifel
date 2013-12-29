class MarketingMultimediaMessage < ActiveRecord::Base

  has_attached_file :content,
    :url => "/admin/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:style/:basename.:extension"

#  has_attached_file :multimedia,
#    :url => ':s3_domain_url',
#    :storage => :s3,
#    :s3_credentials => "#{Rails.root}/config/s3.yml",
#    :s3_credentials => Rails.root.join('config', 's3.yml'),
#    :s3_permissions => 'private', # default => :public_read
#    :s3_protocol => 'http',
#    :bucket => "dev-wickedstart",
#    :path => ":class/:id/:basename.:extension"
#    :path => ":class/:attachment/:id/:basename.:extension"

  def url_for_video_player
#    self.multimedia.url(nil, false)
#    "http://wickedstartbucket.s3.amazonaws.com#{self.content.url(nil, false)}"
#    CGI::escape(AWS::S3::S3Object.url_for(self.multimedia.path, self.multimedia.bucket_name, :expires_in => 1000.seconds))
#    AWS::S3::S3Object.url_for(self.multimedia.path, self.multimedia.bucket_name, :expires_in => 1000.seconds).gsub("?", "&")
    if VIDEOS_ON_S3
      "http://wickedstartbucket.s3.amazonaws.com#{self.content.url(nil, false)}"
    else
      self.content.url(nil, false)
    end
  end

end
