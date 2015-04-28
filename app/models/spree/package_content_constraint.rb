class Spree::PackageContentConstraint < Spree::Base
  belongs_to :package_type
  belongs_to :shipping_category
end
