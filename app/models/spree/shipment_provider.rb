class Spree::ShipmentProvider < Spree::Base
  has_many :package_types, dependent: :destroy, foreign_key: 'provider_id'

  def estimate service_type, package_type, package
    backend.new(service_type, package_type, package).estimate
  end

  def generate_label! service_type, package_type, shipment
    backend.new(service_type, package_type, shipment).generate_label!
  end

  private

  def backend
    self.class.backends.find do |backend|
      backend.name.split('::').last.downcase == name.downcase
    end
  end

  # Stores a list of all available backends
  class_attribute :backends
  self.backends = Set.new

end

# Load backends
require_dependency 'spree/shipment_provider/ups'
require_dependency 'spree/shipment_provider/stamps'
