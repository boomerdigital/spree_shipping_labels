require 'spec_helper'

describe Spree::Calculator::Shipping::QuotedForLabel do

  let(:calculator) do
    Spree::Calculator::Shipping::QuotedForLabel.new do |calc|
      calc.preferred_provider = 'Stamps'
      calc.preferred_service_type = 'USPS First-Class Mail'
      calc.preferred_fallback_price = 10.25
    end
  end

  let(:package) do
    Spree::Stock::Package.new(nil).tap do |pkg|
      pkg.add build :inventory_unit
    end
  end

  it 'will return fallback price if package type cannot be selected' do
    expect( calculator.compute_package package ).to eq 10.25
  end

  it 'will return fallback price if error getting rates' do
    stub_estimation_response nil
    expect( calculator.compute_package package ).to eq 10.25
  end

  it 'will return calculated estimate' do
    stub_estimation_response 8.2
    expect( calculator.compute_package package ).to eq 8.2
  end

  private

  # I generally dislike stubbing in testing but without it in this case the
  # complexity of the tests would exceed the complexity of the code we are
  # testing. So a small bit of stubbing is the lesser of two evils.
  def stub_estimation_response value
    package.singleton_class.send :define_method, :preferred_package_type do |provider_name, service_type|
      p = Object.new
      p.singleton_class.send :define_method, :provider do
        pkg = Object.new
        pkg.singleton_class.send :define_method, :estimate do |service_type, package_type, package|
          value
        end
        pkg
      end
      p
    end
  end

end
