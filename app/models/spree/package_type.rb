class Spree::PackageType < Spree::Base

  belongs_to :provider, class_name: 'Spree::ShipmentProvider'
  has_many :contraints, dependent: :destroy, class_name: 'Spree::PackageContentConstraint'
  has_many :shipments, dependent: :destroy

  # Package types are sorted by volume
  def <=>(other)
    (width * height * length) <=> (other.width * other.height * other.length)
  end

  def can_fit? package
    # Make sure the package doesn't contain items in a shipping category that
    # the package type doesn't support.
    return false unless (package.shipping_categories - supported_shipping_categories).empty?

    # Verify each shipping category supported can support the number in the package
    contraints.all? do |contraint|
      package.in_category(contraint.shipping_category).size <= contraint.max
    end
  end

  def to_s
    "#{name} (#{width}in x #{length}in x #{height}in)"
  end

  private

  # Returns a list of all shipping categories this package type is configured
  # to work with.
  def supported_shipping_categories
    contraints.collect(&:shipping_category).uniq
  end

end
