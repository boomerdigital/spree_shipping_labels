# Provides common functionality to help a package and shipment select a package
# type. The package makes a select when it is estimating and the shipment
# makes a selection when actually printing the label.
#
# In theory they should make the same selection. I thought about trying to
# have the estimating calculator make the selection, attach that selection to
# the rate then have the label printed from the data in the chosen rate. BUT
# there wasn't really a clean way to do that as a calculator really just returns
# a single value (cost) and tacking on data to that value and extracting it in
# the shipping rate seemed more hackish then simply having both the shipment
# and the package individually make the same choice by the face that they
# mix in the same code.
module Spree::PackageTypePicking

  # Returns a list of all shipping categories that are used by the items in
  # this package.
  def shipping_categories
    inventory_units.collect {|i| i.variant.shipping_category }.uniq
  end

  # Returns all the items in the package/shipment that have the given shipping category
  def in_category shipping_category
    inventory_units.find_all { |item| item.variant.shipping_category == shipping_category }
  end

  # Returns all package types that are capable of storing the items in this
  # package/shipment for the given provider. The provider should just be the
  # name and from that this method will find the object
  def possible_package_types_for provider, service_type, must_fit=true
    provider = Spree::ShipmentProvider.find_by name: provider
    return [] unless provider
    provider.package_types.find_all do |type|
      (type.valid_services.nil? || type.valid_services.include?(service_type)) &&
      (!must_fit || type.can_fit?(self))
    end
  end

  # Then return the smallest possible package. This method of selecting package
  # type is somewhat simple. If you have specialized logic for certain items or
  # package types that cannot be represented in data contraints you can override
  # this method in a decorator to apply whatever logic is desired.
  def preferred_package_type provider, service_type
    possible_package_types_for(provider, service_type).sort.first
  end

  # This provides a customization hook to convert the stored weight of the
  # item into oz. All calculations are based on oz. But Spree's weight field
  # is unitless. We are going to assume it is storing oz and therefore this
  # method just returns the stored weight. But if it stores the weight of
  # items in lbs then just add the following to your app in a decorator:
  #
  #     def weight_in_oz
  #       weight * 16
  #     end
  def weight_in_oz
    weight
  end

end
