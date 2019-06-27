module MQTT
  module Homie
    class Node < HomieObject
      homie_id
      homie_attr :name, required: true
      homie_attr :type, required: true
      homie_attr :properties, datatype: Array, required: true, immutable: true

      def property(id)
        @properties.find { |i| i.id == id }
      end

      def homie_attributes
        data = super

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
