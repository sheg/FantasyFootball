require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

Bundler.require(:default, Rails.env)

module FantasyFootball
  class Application < Rails::Application

    #To get rid of annoying warning message on OSX
    config.i18n.enforce_available_locales = false

    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
    config.middleware.use Rack::Deflater
    config.beginning_of_week = :sunday

  end
end