class ApplicationController < ActionController::Base
	include SessionsHelper
	include MicropostsHelper
	protect_from_forgery with: :exception
end
