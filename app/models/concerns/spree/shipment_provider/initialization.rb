module Spree::ShipmentProvider::Initialization

  # A common constructor that all providers can share.
  #
  # service_type::
  #   A provider specific string to indicate the service desired
  #   (1-day, ground, etc.).
  # package_type::
  #   In instance of Spree::PackageType that we are operating on. This provides
  #   the package type info to UPS as well as the dimensions.
  # package:
  #   Either a Spree::Stock::Package or a Spree::Shipment. Both are logically
  #   equivelant. One is just an in-memory structure built during the checkout
  #   phase to help quoting while the other is a database-backed structure
  #   drived from the package once the order has been placed to track the
  #   shipment post-checkout.
  def initialize service_type, package_type, package
    @service_type = service_type
    @package_type = package_type
    @package = package
  end

  # Defaults to being available.
  def available?
    true
  end

end
