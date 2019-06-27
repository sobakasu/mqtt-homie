RSpec.describe MQTT::Homie::DeviceBuilder do
  context "build" do
    it "creates a device" do
      device = described_class.new(id: "device", name: "Device").
        node(id: "node", name: "node", type: "test")
        .property(id: "prop1", enum: [:value1, :value2])
        .property(id: "prop2", datatype: :integer, unit: "%")
        .property(id: "prop3", settable: true).build

      expect(device).to be
      expect(device.id).to eq("device")
      expect(device.nodes.count).to eq(1)
      expect(device.nodes[0].properties.count).to eq(3)
    end
  end
end
