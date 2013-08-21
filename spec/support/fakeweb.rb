# Fakeweb
require 'fakeweb'

FakeWeb.allow_net_connect = false
FakeWeb.register_uri(:any, /http:\/\/api\.mixpanel\.com.*/, :body => "1")
