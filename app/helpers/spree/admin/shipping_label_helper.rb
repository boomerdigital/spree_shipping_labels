module Spree::Admin::ShippingLabelHelper

  # A helper that outputs a `select` which will display the currently selected
  # package type as well as the opportunity to change to a different package
  # type. When the value is changed an XHR is sent to update the shipments
  # with the new package type. This will in turn generate a new label.
  #
  # Since this selector updates via XHR it can be embedded within another form
  # without affecting that form and the value can be saved/changed without
  # changing/saving the overall form.
  def package_type_selector shipment
    options = shipment.possible_package_types.collect do |package_type|
      [package_type.to_s, package_type.id]
    end
    return if options.empty?
    options.unshift ['-- Not Selected --', ''] unless shipment.package_type_id?
    select_tag nil, options_for_select(options, shipment.package_type_id),
      id: nil, class: 'package-type-selector', data: {
        resource: admin_label_path(shipment_id: shipment.id),
        cost: shipment.label.try(:cost), order: shipment.order_id,
        shipment: shipment.id, insurance: (shipment.insurance_enabled? ? shipment.insurance : nil)
      }
  end

end
