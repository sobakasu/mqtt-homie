module MQTT
  module Homie
    module HomieAttribute
      def self.included(base)
        base.send :include, InstanceMethods
        base.extend ClassMethods
      end

      module ClassMethods
        def homie_attr(name, options = {})
          # define accessors
          attr_reader name

          unless options[:immutable]
            define_method("#{name}=") { |value| homie_attr_set(name, value) }
          end

          # record attribute data
          @homie_attribute_list ||= []
          @homie_attribute_list << [name.to_sym, options]
        end

        def homie_id
          homie_attr :id, required: true, validate: lambda { |i| valid_id?(i) }, immutable: true, hidden: true
        end

        def homie_has_id?
          !!homie_attr_list.detect { |i| i[0] == :id }
        end

        def homie_attr_list
          @homie_attribute_list || []
        end

        def homie_attr_options(name)
          data = homie_attr_list.find { |i| i[0] == name } || []
          data[1] || {}
        end
      end

      module InstanceMethods

        # initialize all homie attributes from the given hash
        def homie_attr_init(data = {})
          self.class.homie_attr_list.each do |name, options|
            #puts "name: #{name}, default: #{options[:default]}, options: #{options.inspect}"
            value = data.include?(name) ? data[name] : options[:default]
            value = value.call(self) if value.kind_of?(Proc)
            homie_attr_set(name, value)
          end
        end

        # set attribute without validation
        def homie_attr_set!(name, value)
          instance_variable_set("@#{name}", value)
        end

        # set attribute with validation
        def homie_attr_set(name, value)
          homie_attr_validate(name, value)
          homie_attr_set!(name, value)
        end

        def homie_attributes
          data = {}
          # if this object has an id, it needs a $ attribute prefix.
          # otherwise assume it is a hierarchical attribute like $stats/* or $fw/*
          attrib_prefix = self.class.homie_has_id? ? "$" : ""
          self.class.homie_attr_list.each do |name, options|
            next if options[:hidden]
            key = options[:topic] || (attrib_prefix + name.to_s)
            value = instance_variable_get("@#{name}")
            next if value == nil
            data[key] = value.kind_of?(Array) ? value.collect { |i| i.id }.join(",") : value
          end
          data
        end

        # attribute validation
        def homie_attr_validate(name, value)
          options = self.class.homie_attr_options(name)

          if value.nil?
            required = options[:required]
            required = required.call(self) if required.kind_of?(Proc)
            raise "#{name} is required for #{object_type} #{@id}" if required
          end

          datatype = options[:datatype]
          if datatype && !value.nil? && !datatype_match?(datatype, value)
            raise "expected #{name} to be a #{datatype} for #{object_type} #{@id}"
          end

          enum = options[:enum]
          if enum.kind_of?(Array) && !value.nil? && !enum.include?(value.to_sym)
            raise "expected #{name} (#{value}) to be one of #{enum.join(",")}"
          end
        end

        private

        def object_type
          self.class.name.split("::").last
        end

        def valid_id?(id)
          id && id.kind_of?(String) && id.match(/^[-a-z0-9]+$/) && !id.start_with?("-")
        end

        def datatype_match?(datatype, value)
          return value.kind_of?(datatype) if datatype.kind_of?(Class)
          case datatype
          when :boolean
            return value == true || value == false
          else
            raise "unhandled datatype '#{datatype}'"
          end
          false
        end

        #@settable = !!set(options, :settable, default: false)
      end
    end
  end
end
