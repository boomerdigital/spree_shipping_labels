require_dependency 'spree/shipment_provider/active_shipping'

class Spree::ShipmentProvider::Stamps
  # Mixin functionality shared with other providers
  include Spree::ShipmentProvider::Initialization
  include Spree::ShipmentProvider::ActiveShipping

  # Register this backend
  Spree::ShipmentProvider.backends << self

  def generate_label!
    add_ons = ['SC-A-HP'] # Make the postage cost hidden on the printout

    # Only assign the insurance add-on IF the package has insurable value
    add_ons << 'SC-A-INS' if package_for_label.value

    response = io.create_shipment from_location, to_location, package_for_label, [],
      service: ActiveShipping::Stamps::SERVICE_TYPES.invert[@service_type], add_ons: add_ons
    ActiveRecord::Base.transaction do
      @package.update_attributes! tracking: response.tracking_number
      label = @package.label || @package.build_label
      label.cost = response.rate.price.to_f / 100
      label.label_image = response.label_url
      label.save!
      label
    end if response.success?
  end

  protected

  def config options
    {
      username:       options['username'],
      password:       options['password'],
      integration_id: options['integration_id'],
    }
  end
end
