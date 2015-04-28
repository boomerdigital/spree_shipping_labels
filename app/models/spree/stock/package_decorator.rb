Spree::Stock::Package.class_eval do
  include Spree::PackageTypePicking

  # To provide the same interface as Spree::Shipment so our package picking
  # can interact with either model polymorphically.
  def inventory_units
    contents.collect &:inventory_unit
  end

  # To provide the same interface as Spree::Shipment so our estimating can
  # interact with either model polymorphically.
  def address
    order.try :ship_address
  end
end
