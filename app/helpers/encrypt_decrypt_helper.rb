module EncryptDecryptHelper
  def self.encrypt(value)
    @SECRET = ENV['HASHER']
    @CIPHER = 'aes-256-cbc'

    crypt = ActiveSupport::MessageEncryptor.new(@SECRET, @CIPHER)
    crypt.encrypt_and_sign(value)
  end

  def self.decrypt(value)
    @SECRET = ENV['HASHER']
    @CIPHER = 'aes-256-cbc'

    crypt = ActiveSupport::MessageEncryptor.new(@SECRET, @CIPHER)
    crypt.decrypt_and_verify(value)
  end
end
