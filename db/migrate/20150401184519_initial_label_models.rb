class InitialLabelModels < ActiveRecord::Migration
  def change
    add_column :spree_shipments, :package_type_id, :integer

    create_table :spree_shipment_providers do |t|
      t.string :name, null: false
    end

    create_table :spree_package_types do |t|
      t.belongs_to :provider, null: false
      t.string :valid_services, array: true
      t.decimal :width, :length, :height, precision: 6, scale: 2, null: false
      t.string :provider_type, :name, null: false
    end

    create_table :spree_package_content_constraints do |t|
      t.belongs_to :package_type, null: false
      t.belongs_to :shipping_category, null: false
      t.integer :max, null: false
    end

    create_table :spree_labels do |t|
      t.belongs_to :shipment, null: false
      t.decimal :cost, precision: 8, scale: 2
      t.string :label_image_file_name, :label_image_content_type
    end

  end
end
