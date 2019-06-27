module MQTT
  module Homie
    class Node < HomieObject
      attr_reader :name, :properties

      def initialize(options = {})
        super(options)
        @name = set(options, :name, required: true)
        @type = set(options, :type, required: true)
        @properties = set(options, :properties, required: true, data_type: Array)
      end

      def property(id)
        @properties.find { |i| i.id == id }
      end

      def homie_attributes
        data = {
          "$name" => @name,
          "$type" => @type,
          "$properties" => @properties.collect { |i| i.id }.join(","),
        }

        @properties.each do |p|
          p.homie_attributes.each do |k, v|
            data[p.topic + "/" + k] = v
          end
          data[p.topic] = p.value
        end
        data
      end
    end
  end
end
