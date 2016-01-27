if Rails.env.production?
	CarrierWave.configure do |config|
		config.dropbox_app_key = ENV["APP_KEY"]
		config.dropbox_app_secret = ENV["APP_SECRET"]
		config.dropbox_access_token = ENV["ACCESS_TOKEN"]
		config.dropbox_access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
		config.dropbox_user_id = ENV["USER_ID"]
		config.dropbox_access_type = "app_folder"
	end
elsif Rails.env.test?
	CarrierWave.configure do |config|
		config.enable_processing = false
	end	
end