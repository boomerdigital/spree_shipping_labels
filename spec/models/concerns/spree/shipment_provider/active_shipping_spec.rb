require 'spec_helper'

describe Spree::ShipmentProvider::ActiveShipping do
  # We are testing the mixin but using a concrete class that uses the mixing to
  # avoid needing to mock our own.
  let(:klass) { Spree::ShipmentProvider::Stamps }

  it 'can convert a spree stock location to a ActiveShipping location' do
    package = Spree::Stock::Package.new build :stock_location
    provider = klass.new nil, nil, package
    location = provider.send :from_location
    expect( location.company_name ).to eq 'Spree Demo Site'
    expect( location.phone ).to eq '(202) 456-1111'
    expect( location.address1 ).to eq '1600 Pennsylvania Ave NW'
    expect( location.address2 ).to be nil
    expect( location.city ).to eq 'Washington'
    expect( location.state ).to eq 'AL'
    expect( location.zip ).to eq '20500'
    expect( location.country.name ).to eq 'United States'
  end

  it 'can convert a spree address to an ActiveShipping location' do
    package = Spree::Stock::Package.new nil
    inventory_unit = build :inventory_unit
    inventory_unit.order.ship_address = build :address
    package.add inventory_unit
    provider = klass.new nil, nil, package
    location = provider.send :to_location
    expect( location.company_name ).to eq 'Company'
    expect( location.phone ).to eq '555-555-0199'
    expect( location.address1 ).to eq '10 Lovely Street'
    expect( location.address2 ).to eq 'Northwest'
    expect( location.city ).to eq 'Herndon'
    expect( location.state ).to eq 'AL'
    expect( location.zip ).to eq '35005'
    expect( location.country.name ).to eq 'United States'
  end

  describe 'build package' do
    let(:package_type) { Spree::PackageType.new length: 12.5, width: 9, height: 2, provider_type: 'Package' }

    it 'from spree package' do
      inventory_unit = build :inventory_unit
      inventory_unit.variant.update_attribute :weight, 8.2
      package = Spree::Stock::Package.new nil
      package.add inventory_unit
      provider = klass.new 'USPS First Class', package_type, package
      pkg = provider.send :package_for_label
      expect( pkg.ounces.to_f ).to eq 8.2
      expect( pkg.inches(:length) ).to eq 12.5
      expect( pkg.inches(:width) ).to eq 9
      expect( pkg.inches(:height) ).to eq 2
    end

    describe 'from spree shipment' do
      before do
        @shipment = create :shipment, order: create(:order_with_line_items), state: 'ready', insurance: 5.25
        @shipment.order.line_items.first.variant.update_attribute :weight, 8.2
        @provider = klass.new 'USPS First Class', package_type, @shipment
      end

      it 'with insurance enabled' do
        @shipment.update_attributes! insurance_enabled: true
        pkg = @provider.send :package_for_label

        expect( pkg.ounces.to_f ).to eq 8.2
        expect( pkg.inches(:length) ).to eq 12.5
        expect( pkg.inches(:width) ).to eq 9
        expect( pkg.inches(:height) ).to eq 2
        expect( pkg.value ).to eq 525
      end

      it 'with no insurance' do
        @shipment.update_attributes! insurance_enabled: false
        pkg = @provider.send :package_for_label
        expect( pkg.value ).to eq nil
      end
    end
  end

  it 'can guess the activeshipping provider name' do
    provider = klass.new nil, nil, nil
    expect( provider.send :provider_name ).to eq 'Stamps'
  end

end
