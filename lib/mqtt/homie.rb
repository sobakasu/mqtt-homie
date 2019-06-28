require "mqtt"
require "mqtt/homie/version"

module MQTT
  module Homie
    class Error < StandardError; end

    class << self
      attr_accessor :logger

      def debug(message)
        logger.debug(message) if logger
      end

      def device_builder(options = {})
        MQTT::Homie::DeviceBuilder.new(options)
      end
    end
  end
end

require "mqtt/homie/homie_attribute"
require "mqtt/homie/homie_object"
require "mqtt/homie/network"
require "mqtt/homie/property"
require "mqtt/homie/node"
require "mqtt/homie/device"
require "mqtt/homie/client"
require "mqtt/homie/device_builder"
