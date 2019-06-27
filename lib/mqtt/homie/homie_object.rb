require "observer"

module MQTT
  module Homie
    class HomieObject
      include HomieAttribute

      def initialize(options = {})
        homie_attr_init(options)
      end

      def topic
        @id
      end
    end
  end
end
