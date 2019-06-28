require "sys/uname"
require "socket"

module MQTT
  module Homie
    class Device < HomieObject
      class << self
        include Network
      end

      HOMIE_VERSION = "3.0.1"
      DEFAULT_STAT_REFRESH = 60  # seconds
      DEFAULT_IMPLEMENTATION = "mqtt-homie-#{VERSION}"

      class Firmware < HomieObject
        class << self
          def default_fw_name
            uname.sysname rescue uname.caption rescue "Unknown"
          end

          def default_fw_version
            uname.release rescue uname.build_number rescue "Unknown"
          end

          def uname
            @uname ||= Sys::Uname.uname
          end
        end

        homie_attr :name, default: default_fw_name, required: true
        homie_attr :version, default: default_fw_version, required: true
      end

      # statistics should be sent every interval seconds
      # homie/device_id/$stats
      class Statistics < HomieObject
        homie_attr :interval, required: true, default: 60
        homie_attr :boot_time, default: lambda { |i| Time.now }, hidden: true
        homie_attr :signal, datatype: Integer
        homie_attr :cputemp, datatype: Integer
        homie_attr :cpuload, datatype: Float
        homie_attr :battery, datatype: Integer
        homie_attr :freeheap, datatype: Integer
        homie_attr :supply, datatype: Float

        def homie_attributes
          super.merge("uptime" => (Time.now - @boot_time).to_i)
        end
      end

      attr_reader :fw, :stats
      attr_accessor :use_stats, :use_fw

      homie_id
      homie_attr :name, required: true
      homie_attr :state, default: :init, required: true
      homie_attr :nodes, datatype: Array, default: [], immutable: true
      homie_attr :localip, default: default_localip, required: true
      homie_attr :mac, default: default_mac, required: true
      homie_attr :implementation, default: DEFAULT_IMPLEMENTATION

      def initialize(options = {})
        super(options)
        @stats = Statistics.new(options)
        @fw = Firmware.new(subhash(options, "fw_"))

        @use_stats = options.include?(:use_stats) ? options[:use_stats] : true
        @use_fw = options.include?(:use_fw) ? options[:use_fw] : true
      end

      def node(id)
        @nodes.find { |i| i.id == id }
      end

      # device attributes must be sent when connection to broker is established or re-established
      # homie/device_id/
      def homie_attributes
        data = super.merge({
          "$homie" => HOMIE_VERSION,
        })

        data.merge!({
          "$fw/name" => @fw.name,
          "$fw/version" => @fw.version,
        }) if @use_fw

        @nodes.each do |node|
          node.homie_attributes.each do |k, v|
            data[node.topic + "/" + k] = v
          end
        end
        data
      end

      private

      def subhash(data, prefix)
        result = {}
        data.each do |key, value|
          next unless key.to_s.start_with?(prefix)
          key = key.to_s.sub(/^#{prefix}/, "")
          result[key.to_sym] = value
        end
        result
      end
    end
  end
end
