require 'minitest/spec'
require 'minitest/autorun'
require 'connect_client/security/filtered_key_generation'

describe ConnectClient::Security do
  it "should generate a symmetrical filtered key" do
    keyJson = '{"filters":{"customerId":5},"canPush":false,"canQuery":true}'
    master_key = "2fMSlDSOGtMWH50wffnCscgGMcJGMQ0s"
    filtered_key = ConnectClient::Security.generate_filtered_key(keyJson, master_key)
    generated_key_json = ConnectClient::Security.generate_key_json(filtered_key, master_key)
    generated_key_json.must_equal keyJson
  end
end