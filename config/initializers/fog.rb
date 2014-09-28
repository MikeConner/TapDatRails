CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',       # required
    :aws_access_key_id      => ENV['AWS_KEY_ID'].nil? ? 'AKIAJN2CUVGNNRK4KLFA' : ENV['AWS_KEY_ID'],       # required
    :aws_secret_access_key  => ENV['AWS_SECRET_KEY_ID'].nil? ? '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' : ENV['AWS_SECRET_KEY_ID'],       # required
    :region                 => 'us-east-1'  # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = ENV['FOG_DIRECTORY'].nil? ? 'tapdat' : ENV['FOG_DIRECTORY']
#  config.fog_host       = 'https://assets.example.com'            # optional, defaults to nil
#  config.fog_public     = false                                   # optional, defaults to true
#  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}

  if Rails.env.test?
    config.enable_processing = false
    Fog.mock!
    connection = Fog::Storage.new(:provider => 'AWS', 
                                  :aws_access_key_id => 'AKIAJN2CUVGNNRK4KLFA', 
                                  :aws_secret_access_key => '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',
                                  :region => 'us-east-1')
    connection.directories.create(:key => 'null')
  else
    config.storage = :fog
  end
end
