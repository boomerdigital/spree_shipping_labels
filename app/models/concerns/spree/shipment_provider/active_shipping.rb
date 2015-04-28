# Provides functionality to convert Spree locations/packages into ActiveShipping
# models for interaction with the ActiveShipping library. Also implements the
# estimate interface since that is standardized in ActiveShipping across
# providers.
module Spree::ShipmentProvider::ActiveShipping

  # Unlike the label generation, the rates provide a uniform interface so we
  # can implement it here instead of on each providers.
  def estimate
    begin
      rates = io.find_rates(from_location, to_location, package_for_label).rates
      rate = rates.find_all {|r| r.service_name == @service_type}.sort_by(&:price).first
      rate.price.to_f / 100 if rate
    rescue ::ActiveShipping::ResponseError
      # Do nothing, nil is returned which triggers the fallback price
    end
  end

  protected

  # Returns the handle to carrier specific API
  def io
    @io ||= begin
      secrets = Rails.application.secrets.public_send provider_name.downcase
      options = config secrets
      options[:test] = secrets.has_key?('test_model') ? secrets['test_mode'] : true
      ::ActiveShipping.const_get(provider_name).new(options).tap {|io| io.logger = Rails.logger}
    end
  end

  # Returns an ActiveShipping::Location to describe where the package is
  # coming from. This information is derived from the stock location associated
  # with the package/shipment.
  def from_location
    # Use the stock location associated with the package/shipment to determine
    # the from location.
    location = @package.stock_location
    @from_location ||= ::ActiveShipping::Location.new \
      company_name: Spree::Store.current.name,
      phone: location.phone,
      address1: location.address1,
      address2: (location.address2? ? location.address2 : nil),
      city: location.city,
      state: (location.state ? location.state.abbr : nil),
      zip: location.zipcode,
      country: (location.country ? location.country.iso : nil)
  end

  # Returns an ActiveShipping::Location to describe where the package is
  # going to. This information is derived from the address on the package/shipment
  def to_location
    addr = @package.address
    @to_location ||= ::ActiveShipping::Location.new \
      company_name: (addr.company? ? addr.company : nil),
      name: "#{addr.firstname} #{addr.lastname}",
      phone: addr.phone,
      address1: addr.address1,
      address2: (addr.address2? ? addr.address2 : nil),
      city: addr.city,
      state: (addr.state ? addr.state.abbr : nil),
      zip: addr.zipcode,
      country: (addr.country ? addr.country.iso : nil)
  end

  # Return an ActiveShipping::Package which we will estimate with and generate
  # a label for. This information is based on the package_type and
  # package/shipment given to the initializer
  def package_for_label
    @package_for_label ||= ::ActiveShipping::Package.new @package.weight_in_oz,
      [@package_type.length, @package_type.width, @package_type.height],
      units: :imperial, package_type: package_type_code(@package_type.provider_type)
  end

  def provider_name
    self.class.name.split('::').last
  end

  def package_type_code package_type
    package_type
  end

end
