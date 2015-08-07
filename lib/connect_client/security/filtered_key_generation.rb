require 'openssl'

module ConnectClient
  module Security
    def self.generate_filtered_key2(queryJson, master_key)
      key = Digest::SHA256.digest(master_key)
      cipher = OpenSSL::Cipher::AES256.new(:CBC)
      cipher.encrypt
      cipher.key = key
      iv = cipher.random_iv

      puts queryJson
      encrypted = cipher.update(queryJson)
      encrypted << cipher.final
      puts encrypted.length

      filtered_key = "#{ConnectClient::Security.bin_to_hex(iv)}-#{ConnectClient::Security.bin_to_hex(encrypted)}"
      puts filtered_key
      filtered_key
    end

    def self.generate_filtered_key(query_json, master_key)
      key = master_key
      key = Digest::SHA256.digest(key) if(key.kind_of?(String) && 32 != key.bytesize)
      aes = OpenSSL::Cipher.new('AES-256-CBC')
      iv = aes.random_iv
      aes.encrypt
      aes.key = key
      aes.iv = iv
      encrypted = aes.update(query_json) + aes.final

      "#{ConnectClient::Security.bin_to_hex(iv)}-#{ConnectClient::Security.bin_to_hex(encrypted)}"
    end

    def self.bin_to_hex(s)
      s.unpack("H*").first.to_s.upcase
    end
  end
end