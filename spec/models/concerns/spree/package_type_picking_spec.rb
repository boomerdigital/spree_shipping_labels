require 'spec_helper'

describe Spree::PackageTypePicking do

  let(:package) do
    Spree::Stock::Package.new(nil).tap do |pkg|
      @c1 = create :shipping_category
      @c2 = create :shipping_category

      p1 = create :product, shipping_category: @c1
      p2 = create :product, shipping_category: @c2
      p3 = create :product, shipping_category: @c2

      l1 = create :line_item, variant: p1.master
      l2 = create :line_item, variant: p2.master
      l3 = create :line_item, variant: p3.master

      iu1 = create :inventory_unit, line_item: l1, variant: p1.master
      iu2 = create :inventory_unit, line_item: l2, variant: p2.master
      iu3 = create :inventory_unit, line_item: l3, variant: p3.master

      pkg.add iu1
      pkg.add iu2
      pkg.add iu3
    end
  end

  it 'can return list of all shipping categories in the package' do
    expect( package.shipping_categories ).to eq [@c1, @c2]
  end

  it 'can returns the items in a specific shipping category' do
    expect( package.in_category(@c1).size ).to eq 1
    expect( package.in_category(@c2).size ).to eq 2
  end

  describe 'picking' do
    let(:provider) do
      pkg_attrs = {width: 10, length: 10, height: 2}
      Spree::ShipmentProvider.create! do |provider|
        provider.name = 'Bogus'
        @no_services = provider.package_types.build pkg_attrs.merge(provider_type: 'no_services', name: 'No Services')
        @with_services = provider.package_types.build pkg_attrs.merge(valid_services: ['1-day', '2-day'], provider_type: 'with_services', name: 'With Services')
      end
    end
    before { provider }

    it 'will include a package type if it has no valid services defined and skip when it does not include the desired service' do
      actual = package.possible_package_types_for 'Bogus', '3-day', false
      expect( actual ).to eq [@no_services]
    end

    it 'will include a package type if the desired service is a valid service' do
      actual = package.possible_package_types_for 'Bogus', '1-day', false
      expect( actual ).to eq [@no_services, @with_services]
    end

    it 'will skip pacakge type that do not fit if fitting is required' do
      expect( package.possible_package_types_for 'Bogus', '1-day' ).to eq []
    end

    describe 'with contraints' do
      before do
        package
        @no_services.contraints.create! shipping_category: @c1, max: 1
        @no_services.contraints.create! shipping_category: @c2, max: 2
        @with_services.contraints.create! shipping_category: @c1, max: 1
        @with_services.contraints.create! shipping_category: @c2, max: 2
      end

      it 'will not skip packages type that do not fit if fitting is not required' do
        actual = package.possible_package_types_for 'Bogus', '1-day'
        expect( actual ).to eq [@no_services, @with_services]
      end

      it 'will return the smallest possible package type' do
        @no_services.update_attributes! width: 5, length: 5, height: 1
        expect( package.preferred_package_type 'Bogus', '1-day' ).to eq @no_services
      end
    end
  end

end
