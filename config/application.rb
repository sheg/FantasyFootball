require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

Bundler.require(:default, Rails.env)

module FantasyFootball
  class Application < Rails::Application

    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
    config.middleware.use Rack::Deflater

  end
end