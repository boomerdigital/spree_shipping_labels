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

    estimate = package_type.provider.estimate preferred_service_type, package_type, package
    return preferred_fallback_price unless estimate

    estimate
  end

end
