require 'spec_helper'

describe Spree::PackageType do

  it 'can compare package type sizes' do
    bigger = Spree::PackageType.new width: 10, length: 9, height: 5
    smaller = Spree::PackageType.new width: 11, length: 10, height: 1
    expect( smaller <=> bigger ).to eq -1
  end

  describe 'calculate fitting' do

    %w(valid invalid).each do |type|
      let(:"#{type}_category") { create :shipping_category }
      let(:"#{type}_product") { create :product, shipping_category: send(:"#{type}_category") }
      let(:"#{type}_variant") { create :variant, product: send(:"#{type}_product") }
      let(:"#{type}_line_item") { create :line_item, variant: send(:"#{type}_variant") }
      let(:"#{type}_inventory_unit") do
        Spree::InventoryUnit.new \
          line_item: send(:"#{type}_line_item"), variant: send(:"#{type}_variant")
      end
    end

    let(:package_type) do
      Spree::PackageType.new do |package_type|
        package_type.contraints.build shipping_category: valid_category, max: 5
      end
    end

    it 'will not fit if package contains categtories this package type does not support' do
      package = Spree::Stock::Package.new nil
      package.add valid_inventory_unit
      package.add invalid_inventory_unit
      expect( package_type.can_fit? package ).to eq false
    end

    it 'will not fit if there are too many of a specific category' do
      package = Spree::Stock::Package.new nil
      10.times do
        iu = Spree::InventoryUnit.new line_item: valid_line_item, variant: valid_variant
        package.add iu
      end
      expect( package_type.can_fit? package ).to eq false
    end

    it 'will fit if there are fewer than the package type supports' do
      package = Spree::Stock::Package.new nil
      package.add valid_inventory_unit
      expect( package_type.can_fit? package ).to eq true
    end

  end

  it 'can be strigified into a descriptive label' do
    subject = Spree::PackageType.new name: 'Box', width: 12, height: 2.5, length: 9
    expect( subject.to_s ).to eq 'Box (12.0in x 9.0in x 2.5in)'
  end

end
