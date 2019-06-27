# MQTT::Homie

A ruby interface for creating a device conforming to the MQTT [Homie] convention.
This gem builds upon the [ruby-mqtt] ruby gem.

The [Homie] convention defines a standardized way of how IoT devices and services announce themselves and their data to a MQTT broker.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mqtt-homie'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mqtt-homie

## Quick Start

~~~ ruby
require 'rubygems'
require 'mqtt/homie'

# Set up a device, with a node and properties
device = MQTT::Homie.device_builder(id: 'device', name: 'Device'
        localip: '192.168.1.1',
        mac: '80:1f:02:cc:15:dd'
      ).node(id: "gate", name: "Front gate", type: "Gate")
        .property(id: "state", name: "Gate state", enum: [:open, :closed, :opening, :closing], value: :closed)
        .property(id: "position", name: "Gate position", datatype: :integer, unit: "%", value: 0)
        .property(id: "command", name: "Send gate command", settable: true, enum: [:open, :close]).build

# Create a client and connect to a MQTT broker
client = MQTT::Homie::Client.new(device: device, host: 'localhost')
client.connect

# access nodes and properties of the device
node = device.node('gate')
state = node.property('state')
state.value = :open  # publishes new state to MQTT

# listen for changes to properties via the Observer interface
node.property('command').add_observer(self)
~~~

## Overview

TODO

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mqtt::Homie project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/mqtt-homie/blob/master/CODE_OF_CONDUCT.md).



[Homie]: https://homieiot.github.io/
[MQTT]:  http://www.mqtt.org/
[ruby-mqtt]: https://github.com/njh/ruby-mqtt