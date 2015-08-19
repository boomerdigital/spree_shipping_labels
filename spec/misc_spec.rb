require 'spec_helper'

describe ActiveShipping::Location do

  it 'indicates po box if manually set (stock behavior)' do
    expect( ActiveShipping::Location.new(address_type: 'po_box').po_box? ).to eq true
  end

  it 'can detect po boxes' do
    yes = [
      # "box" can be substituted for "bin"
      "#123", "Box 123", "Box-122", "Box122", "HC73 P.O. Box 217",
      "P O Box125", "P. O. Box", "P.O 123", "P.O. Box 123", "P.O. Box",
      "P.O.B 123", "P.O.B. 123", "P.O.B.", "P0 Box", "PO 123", "PO Box N",
      "PO Box", "PO-Box", "POB 123", "POB", "POBOX123", "Po Box", "Post 123",
      "Post Box 123", "Post Office Box 123", "Post Office Box", "box #123",
      "box 122", "box 123", "number 123", "p box", "p-o box", "p-o-box",
      "p.o box", "p.o. box", "p.o.-box", "p.o.b. #123", "p.o.b.", "p/o box",
      "po #123", "po box 123", "po box", "po num123", "po-box", "pobox",
      "pobox123", "post office box"
    ]
    expect( yes.all? {|t| ActiveShipping::Location.new(address1: t).po_box? }).to eq true
  end

  it 'cannot be fooled' do
    no = [
      "The Postal Road", "Box Hill", "123 Some Street",
      "Controller's Office", "pollo St.", "123 box canyon rd",
      "777 Post Oak Blvd", "PSC 477 Box 396", "RR 1 Box 1020"
    ]
    expect( no.any? {|t| ActiveShipping::Location.new(address1: t).po_box? }).to eq false
  end

end
