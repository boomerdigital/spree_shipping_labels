class InsuranceEnabled < ActiveRecord::Migration

  def change
    add_column :spree_shipments, :insurance_enabled, :boolean, null: false, default: false
    say_with_time 'enabling insurance on historical shipped shipments' do
      Spree::Shipment.shipped.update_all insurance_enabled: true
    end
  end

end
