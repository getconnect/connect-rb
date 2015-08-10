require 'openssl'

module ConnectClient
  module Security
    def self.generate_filtered_key(query_json, master_key)
      key = master_key
      key = Digest::SHA256.digest(key) if(key.kind_of?(String) && 32 != key.bytesize)
      aes = OpenSSL::Cipher.new('AES-256-CBC')
      iv = aes.random_iv
      aes.encrypt
      aes.key = key
      aes.iv = iv
      encrypted = aes.update(query_json) + aes.final

      "#{bin_to_hex(iv)}-#{bin_to_hex(encrypted)}"
    end

    def self.generate_query_json(filtered_key, master_key)
      iv_and_data = filtered_key.split('-')      
      iv = hex_to_bin(iv_and_data[0])
      encrypted_query_json = hex_to_bin(iv_and_data[1])

      key = master_key
      key = Digest::SHA256.digest(key) if(key.kind_of?(String) && 32 != key.bytesize)
      iv = Digest::MD5.digest(iv) if(iv.kind_of?(String) && 16 != iv.bytesize)
      aes = OpenSSL::Cipher.new('AES-256-CBC')      
      aes.decrypt
      aes.key = key
      aes.iv = iv
      aes.update(encrypted_query_json) + aes.final
    end

    def self.bin_to_hex(binary_string)
      binary_string.unpack("H*").first.to_s.upcase
    end

    def self.hex_to_bin(hex_string)
      hex_string.scan(/../).map { |x| x.hex }.pack('c*')
    end
  end
end