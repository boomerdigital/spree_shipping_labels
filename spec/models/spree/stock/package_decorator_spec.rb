require 'spec_helper'

describe Spree::Stock::Package do
  let(:package) { Spree::Stock::Package.new nil }

  it 'can return all associated inventory units' do
    i1 = create :inventory_unit
    i2 = create :inventory_unit
    package.add i1
    package.add i2
    expect( package.inventory_units ).to eq [i1, i2]
  end

  it 'can return the order ship address' do
    i = create :inventory_unit
    address = build :address
    i.order.ship_address = address
    package.add i
    expect( package.address ).to eq address
  end

end
