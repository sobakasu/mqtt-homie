module MQTT
  module Homie
    class DeviceBuilder
      def initialize(options = {})
        @nodes = []
        @device_options = options
      end

      # create device and return it
      def build
        build_node if @node_data
        MQTT::Homie::Device.new(@device_options.merge(nodes: @nodes))
      end

      def node(options = {})
        raise "node key/value list expected" unless options.kind_of?(Hash)
        build_node if @node_data
        @node_data = options
        @properties = []
        self
      end

      def property(options = {})
        raise "property key/value list expected" unless options.kind_of?(Hash)
        @properties << MQTT::Homie::Property.new(options)
        self
      end

      private

      def build_node
        @nodes << MQTT::Homie::Node.new(@node_data.merge(properties: @properties))
        @node_data = nil
        @propertes = nil
      end
    end
  end
end
