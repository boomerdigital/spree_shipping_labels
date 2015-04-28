# A label stores the generated label. The system attempts to "print" it (download
# and save) as soon as the order is complete. If it does not have enough
# information to create a label (cannot determine package size) it can be
# generated label in the backend interface once a package type is assigned.
#
# The label has a state machine that the provider manipulates. It is initially
# `nil` but once the pending label has been initialized it will be "pending".
# Once the "pending" data has been accepted it goes to "accepted".
class Spree::Label < Spree::Base
  belongs_to :shipment, class_name: 'Spree::Shipment'

  has_attached_file :label_image
  validates_attachment_content_type :label_image, content_type: ["image/gif", "image/jpeg", "image/png"]
end
