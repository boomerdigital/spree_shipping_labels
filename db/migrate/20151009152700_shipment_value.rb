class ShipmentValue < ActiveRecord::Migration

  def change
    add_column :spree_shipments, :insurance, :decimal, precision: 10, scale: 2
    say_with_time 'assigning insurance value' do
      Spree::Shipment.all.each &:save!
    end
  end

end
