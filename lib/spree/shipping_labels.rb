require 'spree_core'
require 'active_shipping'

class ActiveShipping::Location
  # Yea, a bit crazy. Borrowed from
  PO_REGEXP = /^ *((#\d+)|((box|bin)[-. \/\\]?\d+)|(.*p[ \.]? ?(o|0)[-. \/\\]? *-?((box|bin)|b|(#|num)?\d+))|(p(ost)? *(o(ff(ice)?)?)? *((box|bin)|b)? *\d+)|(p *-?\/?(o)? *-?box)|post office box|((box|bin)|b) *(number|num|#)? *\d+|(num|number|#) *\d+)/i

  # Override to try to automatically detect if an address is a P.O. Box
  def po_box?
    # Original implementation. Still allow it to be manually set
    (@address_type == 'po_box') ||
    (1..3).any? { |i| public_send("address#{i}") =~ PO_REGEXP }
  end

end

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
