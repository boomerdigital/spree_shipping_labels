require_dependency 'spree/shipment_provider/active_shipping'

class Spree::ShipmentProvider::Ups
  # Mixin functionality shared with other providers
  include Spree::ShipmentProvider::Initialization
  include Spree::ShipmentProvider::ActiveShipping

  # Register this backend
  Spree::ShipmentProvider.backends << self

  # :method: initialize
  #
  # The `server_type` parameter should be one of the strings defined in
  # ActiveShipping::Ups::DEFAULT_SERVICES

  def generate_label!
    response = io.create_shipment from_location, to_location, package_for_label,
      service_code: ActiveShipping::UPS::DEFAULT_SERVICE_NAME_TO_CODE[@service_type]
    label_data = response.labels.first

    ActiveRecord::Base.transaction do
      @package.update_attributes! tracking: label_data[:tracking_number]
      label = @package.label || @package.build_label
      label.cost = response.params['ShipmentResults']['ShipmentCharges']['TotalCharges']['MonetaryValue']
      label.label_image = "data:image/#{label_data[:image]['LabelImageFormat']['Code'].downcase};base64,#{label_data[:image]['GraphicImage']}"
      label.label_image_file_name = 'label.gif'
      label.save!
      label
    end
  end

  def available?
    super && !to_location.po_box?
  end

  protected

  def config options
    {
      login:          options['user_id'],
      password:       options['password'],
      key:            options['license_number'],
      origin_account: options['account_number'],
      pickup_type:    (options['pickup_type'] || 'suggested_retail_rates').to_sym
    }
  end

  # Override since it is all uppercase
  def provider_name
    'UPS'
  end

  # Override to convert nice name to code for API
  def package_type_code package_type
    ::ActiveShipping::UPS::PACKAGE_TYPES[package_type]
  end

end

class ActiveShipping::UPS

  PACKAGE_TYPES = {
    'Letter' => "01",
    'Customer Supplied Package' => "02",
    'Tube' => "03",
    'PAK' => "04",
    'UPS Express Box' => "21",
    'UPS 25kg Box' => "24",
    'UPS 10kg Box' => "25",
    'Pallet' => "30",
    'Small Express Box' => "2a",
    'Medium Express Box' => "2b",
    'Large Express Box' => "2c",
    'Flats' => "56",
    'Parcels' => "57",
    'BPM' => "58",
    'First Class' => "59",
    'Priority' => "60",
    'Machinables' => "61",
    'Irregulars' => "62",
    'Parcel Post' => "63",
    'BPM Parcel' => "64",
    'Media Mail' => "65",
    'BPM Flat' => "66",
    'Standard Flat' => "67",
  }

  def build_package_node_with_package_type xml, package, options = {}
    build_package_node_without_package_type xml, package, options
    xml.doc.at('//PackagingType/Code').content = package.options[:package_type] if package.options[:package_type]
  end
  alias_method_chain :build_package_node, :package_type unless instance_methods.include? :build_package_node_without_package_type
end
