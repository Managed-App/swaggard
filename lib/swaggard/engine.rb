# frozen_string_literal: true

module Swaggard
  # Swaggard Engine
  class Engine < ::Rails::Engine
    isolate_namespace Swaggard

    def rake?
      File.basename($PROGRAM_NAME) == 'rake'
    end

    initializer 'swaggard.finisher_hook' do |app|
      if Rails.env.development? && !rake? && !app.methods.include?(:assets_manifest)
        warn <<~WARNING
          [Swaggard] It seems you are using an api only rails setup, but swaggard
          [Swaggard] web app needs sprockets in order to work. Make sure to add
          [Swaggard] require 'sprockets/railtie'.
          [Swaggard] If you plan to use it
        WARNING
      end

      # rubocop:disable Style/IfUnlessModifier
      Swaggard.configure do |config|
        unless config.controllers_path
          config.controllers_path = "#{app.root}/app/controllers/**/*.rb"
        end

        unless config.models_paths
          config.models_paths = ["#{app.root}/app/serializers/**/*.rb"]
        end

        config.routes = app.routes.routes
      end
      # rubocop:enable Style/IfUnlessModifier

      Swaggard.register_custom_yard_tags!
    end
  end
end
