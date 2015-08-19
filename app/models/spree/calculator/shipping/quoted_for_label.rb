require_dependency 'spree/shipping_calculator'

class Spree::Calculator::Shipping::QuotedForLabel < Spree::ShippingCalculator

  preference :provider, :string
  preference :service_type, :string
  preference :fallback_price, :decimal

  def self.description
    Spree.t :quoted_for_label
  end

  def compute_package package
    package_type = package.preferred_package_type preferred_provider, preferred_service_type
    return preferred_fallback_price unless package_type

    estimate = nil
    begin
      # Don't give the API more than 5 seconds to avoid being slow
      timeout 5 do
        # This could return nil and we still use the fallback price
        estimate = package_type.provider.estimate preferred_service_type, package_type, package
      end
    rescue
      # Any sort of error should be swallowed and the fallback price should be used
    end
    return preferred_fallback_price unless estimate

    estimate
  end

  def available? package
    provider = Spree::ShipmentProvider.find_by name: preferred_provider
    provider.available? preferred_service_type, package
  end

end
