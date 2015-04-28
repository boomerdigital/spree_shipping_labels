Purpose
=======

Support for estimating packages and printing shipping labels for packages.

Status
======

This plugin should be considered still in progress and while it is good enough
to use on the project it was developed for, it will likely need more work to
be generally useful. To get an idea of where it is at:

What It Does
------------

* Support UPS and USPS (through Stamps.com)
* Can get a rate quote as well as labels for the packages
* Can analyze a shipment to determine what type of box can be used.
* Can batch print labels across multiple shipments/orders
* Preliminary functions to allow admin to select a package type if not
  automatically determined (or to override the one selected if automatically
  determined)
* Integrates well with Spree's concept of shipping categories.

What Needs To Be Done
---------------------

* The selector for an admin to control the selected package needs to be placed
  on the stock Spree screen for viewing a shipment (the widget is already
  working but my existing project uses it on a custom order processing screen).
* There needs to be a button on the stock Spree screen for viewing shipments
  that links to the print label action. The controller/view is already in place
  and can operate in a batch mode. But again we are not using the stock screen
  for order processing in our project so we launch from our custom screen. It
  should be launchable from the stock Spree screen.
* The shipping method calculator options should be more helpful in setting
  the service and provider (i.e. some sort of select widget). Since I am
  building on Spree's preferences system they are just plain text fields.
* There should be an admin screen to allow providers, provider packages and
  package contraints to be defined and edited. Right now this is stored in the
  database (so it is configurable and not hard-coded) but there is no interface
  to manage it.
* It would be nice if the plugin had seed data similar to Spree's states that
  would populate provider defined packages (i.e. an express box) so the
  implementer has at least some pre-defined box types without having to research
  the box types of the providers. They can then edit from there.
* We might consider removing the contraints on package types and instead rely
  on machine learning to figure out what types of items and how many can fit
  in a box.

Relation with ActiveShipping
============================

This is conceptually similar to `spree_active_shipping`. In retrospect, it might
have been better to either enhance that plugin or create a plugin that builds
on that plugin. We had two goals which `spree_active_shipping` does not support:

* Generating labels for printing
* Allow multiple items to be put in the same box (`spree_active_shipping`
  assumes each item is in it's own box when it gets a rate quote).

Since `ActiveShipping` just supported getting rates I was looking to gems like
[brownie](https://github.com/mikejaffe/brownie) and
[stamps](https://github.com/mattsears/stamps) to generate the labels and
therefore was not going to build on `ActiveShipping`. My project scope was
expanded to do rate calculations during checkout which meant I did need to
calculate rates. I kept as a distinct plugin since the mashup of multiple gems
(ActiveShipping, brownie, stamps, etc) is really out of the scope of
`spree_active_shipping`. As I was doing the rate work I realized that
ActiveShipping does have preliminary work for label generation. While still
rough it was a better foundation to build on than `brownie` or `stamps` so I
switched entirely to building on ActiveShipping.

This all means work towards merging the goals of this project with
`spree_active_shipping` would probably benefit both projects, but we are at
the limits of scope on my project so that will have to wait until the future.

Installation
============

To install add the gem to your Gemfile and import the migrations with:

    rake railties:install:migrations

In addition you need to incorporate the CSS and JS in this plugin into the
spree backend asset pipeline by adding:

    //= require spree/backend/shipping-labels

to `vendor/assets/javascripts/spree/backend/all.js`. You also need to add:

    *= require spree/backend/shipping-labels

to `vendor/assets/stylesheets/spree/backend/all.css`.

Finally you will need to build out your provider, packages, constraints,
shipping methods and shipping categories to tune the system for your store.
Right now this is mostly done via seed data.
