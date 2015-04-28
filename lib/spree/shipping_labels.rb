require 'spree_core'
require 'active_shipping'

module Spree::ShippingLabels
  # Thrown if a problem occurs when estimating or generating a label
  class Error < StandardError
  end

  # Supercharge this gem by making it a Rails "engine"
  class Engine < Rails::Engine

    # Put in the same isolated namespace as spree since this is a Spree extension
    isolate_namespace Spree

    # Rails will by default name the engine after the isolated namespace (spree).
    # Override with the name of the gem.
    engine_name 'spree_shipping_labels'

    # Called when the app first boots or anytime the system is reloaded
    def self.activate
      # Cargo culted from other spree plugins so that decorator-style
      # monkey-patches work as expected.
      cache_klasses = %W(#{config.root}/app/**/*_decorator*.rb)
      Dir.glob cache_klasses do |klass|
        Rails.configuration.cache_classes ? require(klass) : load(klass)
      end

      # Add our calculator so it can be selected when setting up the shipment method
      config.spree.calculators.shipping_methods << Spree::Calculator::Shipping::QuotedForLabel

      Spree::Admin::BaseController.helper Spree::Admin::ShippingLabelHelper
    end

    config.to_prepare &method(:activate).to_proc
  end
end
