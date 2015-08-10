require 'minitest/spec'
require 'minitest/autorun'
require 'connect_client/security/filtered_key_generation'

describe ConnectClient::Security do
  it "should generate a symmetrical filtered key" do
    query_json = "{}"
    master_key = "2fMSlDSOGtMWH50wffnCscgGMcJGMQ0s"
    filtered_key = ConnectClient::Security.generate_filtered_key(query_json, master_key)
    generated_query_json = ConnectClient::Security.generate_query_json(filtered_key, master_key)
    generated_query_json.must_equal query_json
  end
end