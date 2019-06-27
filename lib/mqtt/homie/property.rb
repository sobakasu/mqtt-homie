require "observer"

module MQTT
  module Homie
    class Property < HomieObject
      include Observable

      DATA_TYPES = [:integer, :float, :boolean, :string, :enum, :color]

      attr_reader :id, :name, :settable, :datatype, :unit, :retained, :format
      attr_reader :value

      def initialize(options = {})
        super(options)

        options = options.dup

        # enum shortcut
        if enum = options.delete(:enum)
          options[:datatype] = :enum
          options[:format] = enum.collect { |i| i.to_s }.join(',')
        end

        @name = set(options, :name, default: "")
        @settable = !!set(options, :settable, default: false)
        @retained = !!set(options, :retained, default: true)
        @datatype = set(options, :datatype, default: :string, enum: DATA_TYPES).to_sym
        @unit = set(options, :unit, default: "")
        @format = set(options, :format, required: [:enum, :color].include?(@datatype))
        @value = options[:value]
      end

      def value=(value)
        # TODO: check value conforms to expected datatype and format
        if value != @value
          @value = value
          changed
          notify_observers(Time.now, self)
        end
      end

      def settable?
        @settable
      end

      def homie_attributes
        data = {
          "$name" => @name,
          "$settable" => @settable,
          "$datatype" => @datatype,
          "$unit" => @unit,
          "$format" => @format,
          "$retained" => @retained,
        }
        data
      end
    end
  end
end
