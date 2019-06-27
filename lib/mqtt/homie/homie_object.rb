require "observer"

module MQTT
  module Homie
    class HomieObject
      attr_reader :id

      def initialize(options = {})
        @id = set(options, :id, required: true)
        raise "invalid id" unless valid_id?
      end

      def topic
        @id
      end

      def homie_attributes
        {}
      end

      private

      def valid_id?
        @id && @id.kind_of?(String) && @id.match(/^[-a-z0-9]+$/) && !@id.start_with?("-")
      end

      def set(options = {}, name, default: nil, required: false, enum: nil, data_type: nil)
        value = options.include?(name) ? options[name] : default
        raise "#{name} is required for #{object_type} #{@id}" if required && value.nil?
        raise "expected #{name} to be a #{data_type} for #{object_type} #{@id}" if data_type && !value.kind_of?(data_type)
        raise "expected #{name} (#{value}) to be one of #{enum.join(",")}" if enum.kind_of?(Array) && !value.nil? && !enum.include?(value.to_sym)
        value
      end

      def object_type
        self.class.name.split("::").last
      end
    end
  end
end
