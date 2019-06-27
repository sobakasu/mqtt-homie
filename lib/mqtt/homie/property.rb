require "observer"

module MQTT
  module Homie
    class Property < HomieObject
      include Observable

      DATA_TYPES = [:integer, :float, :boolean, :string, :enum, :color]

      homie_id
      homie_attr :name, default: ""
      homie_attr :settable, default: false, datatype: :boolean
      homie_attr :retained, default: true, datatype: :boolean
      homie_attr :datatype, default: :string, enum: DATA_TYPES, datatype: Symbol
      homie_attr :unit, default: ""
      homie_attr :format, required: lambda { |i| [:enum, :color].include?(i.datatype) }

      attr_reader :value

      def initialize(options = {})
        options = options.dup

        # enum shortcut
        if enum = options.delete(:enum)
          options[:datatype] = :enum
          options[:format] = enum.collect { |i| i.to_s }.join(",")
        end

        super(options)

        @value = options[:value]
      end

      def value=(value)
        # TODO: check value conforms to expected datatype and format?
        if value != @value
          @value = value
          changed
          notify_observers(Time.now, self)
        end
      end

      def settable?
        @settable
      end
    end
  end
end
