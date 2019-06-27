RSpec.describe MQTT::Homie::Device do
  context "new" do
    it "creates a device" do
      device = described_class.new(id: "device", name: "test")
      expect(device).to be
      expect(device.id).to eq("device")
    end
  end

  context "homie_attributes" do
    it "has homie attributes" do
      device = described_class.new(id: "device", name: "test")
      data = device.homie_attributes
      expect(data).to be
      expect(data).to include("$name")
    end

    it "includes node attributes" do
      property = MQTT::Homie::Property.new(id: "prop", datatype: "string", name: "test property")
      node = MQTT::Homie::Node.new(id: "node", name: "node", type: "node", properties: [property])
      device = described_class.new(id: "device", name: "Device", nodes: [node])

      data = device.homie_attributes
      #p data
      expect(data).to be
      expect(data).to include("node/prop/$name")
    end
  end
end
