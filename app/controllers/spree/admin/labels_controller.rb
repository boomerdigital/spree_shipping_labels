class Spree::Admin::LabelsController < Spree::Admin::BaseController

  # Outputs a list of shipping labels. Specify either shipment_ids[] or
  # order_ids[] to specify which ones.
  def index
    @shipments = if params[:shipment_ids]
      Spree::Shipment.where id: params[:shipment_ids]
    elsif params[:order_ids]
      Spree::Shipment.where order_id: params[:order_ids]
    else
      Spree::Shipment.none
    end.joins(:label).includes :label
    render layout: 'labels'
  end

  # Will build a new label for the `params[:shipment_id]` by assigning
  # `params[:package_type_id]`. A JSON reprentation of the label is returned.
  #
  # NOTE: If the new `package_type_id` is the same as the old one this is
  # a no-op but the label info is still returned.
  def create
    shipment = Spree::Shipment.find params[:shipment_id]
    shipment.package_type_id = params[:package_type_id]

    # If insurance is provided and it is not 0 then update it also.
    insurance = params[:insurance]
    insurance = nil if insurance.to_f == 0.0
    if insurance.present?
      shipment.insurance_enabled = true
      shipment.insurance = insurance
    else
      shipment.insurance_enabled = false
    end

    shipment.generate_label! if
      shipment.package_type_id_changed? || shipment.insurance_changed? || shipment.insurance_enabled_changed?

    render json: shipment.label, only: %i(cost)
  end

end
