Spree::Shipment.class_eval do
  include Spree::PackageTypePicking

  belongs_to :package_type
  has_one :label, dependent: :destroy
  has_many :variants, through: :inventory_units

  # Unlike Spree::Stock::Package, a shipment doesn't provide a method to get
  # the total weight. Adding here for a polymorphic interface. This uses the
  # `sum` interface which issues a SQL query. In theory we could check if the
  # objects are loaded and total in memory if they are to save a query. But
  # I doubt it will be loaded so no point in complicating the code for an
  # optimization that won't be used.
  def weight
    variants.sum :weight
  end

  # Returns all package types that can possibly be selected. Does not consider
  # if the items can fit as this is for the backend to select a new package
  # type that the automated system may not think is correct
  def possible_package_types
    return [] unless calculator
    possible_package_types_for calculator.preferred_provider, calculator.preferred_service_type, false
  end

  # Will interact with the provider to actually generate a label. The resulting
  # image and other data will be assigned to the related label object.
  def generate_label!
    raise Spree::ShippingLabels::Error, 'Cannot generate a label without a package type' unless package_type
    raise Spree::ShippingLabels::Error, 'Cannot generate a label without a label-able selected shipping method' unless calculator
    package_type.provider.generate_label! calculator.preferred_service_type, package_type, self
  end

  # A shipment is finalized when an order is finalized which happens when an
  # order is complete. We want to extend the shipment finalization to pick
  # a package type (this uses the same code as when a package picks a package
  # type so it should result in the same answer) and store that package type
  # with the shipment. If it was successful at picking a package type it should
  # go ahead and generate the label. This will lock in the pricing.
  #
  # If it cannot pick a package type a label cannot be generated but an admin
  # will still be able to pick a package type and print a label on the backend.
  def finalize_with_label!
    finalize_without_label!

    # Attempt to determine the package type automatically
    if calculator
      preferred = preferred_package_type calculator.preferred_provider, calculator.preferred_service_type
      self.package_type = preferred
      begin
        generate_label!
      rescue
        # Squash the error and remove the info about what package type was
        # selected so it is treated as if we couldn't figure out what package
        # the user needed. The backend user will need to select a package and
        # possibly fix the error.
        self.package_type = nil
      end
    end
  end
  alias_method_chain :finalize!, :label unless instance_methods.include? :finalize_without_label!

  private

  # We custom implement this instead of using `delegate to:` because we only
  # want it to return if the calculator is the right type.
  def calculator
    calc = shipping_method.try :calculator
    calc if Spree::Calculator::Shipping::QuotedForLabel === calc
  end

end
