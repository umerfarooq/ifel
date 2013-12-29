class Credential < ActiveRecord::Base
  require 'ArbApiLib'
  belongs_to :country
  belongs_to :user

  attr_accessible :ip_address, :first_name, :last_name, :address_one, :address_two, :city, :state, :zip_code, :card_type, :card_number, :card_expires_on, :card_verification, :country_id, :card_last_four_digits, :transaction_id, :amount

#  validate :validate_credit_card, :on => :create
#  validates_presence_of :address_one, :city, :state, :zip_code, :country_id
#  after_create :link_transaction_logs

#  before_save :encrypt_sensitive_data

#  def validate_credit_card
#    errors.add_to_base("Credit card information provided appears to be invalid") unless is_card_valid?
#  end

#  def is_card_valid?
#    ActiveMerchant::Billing::CreditCard.new(
#      :type               => self.card_type,
#      :number             => self.card_number,
#      :verification_value => self.card_verification,
#      :month              => self.card_expires_on.month,
#      :year               => self.card_expires_on.year,
#      :first_name         => self.first_name,
#      :last_name          => self.last_name
#    ).valid?
#  end

#  require 'openssl'
#  require 'base64'
#  def encrypt_sensitive_data
#    public_key = OpenSSL::PKey::RSA.new(File.read(PUBLIC_KEY_FILE))
#    self.card_number = Base64.encode64(public_key.public_encrypt(self.card_number))
#    self.card_type = Base64.encode64(public_key.public_encrypt(self.card_type))
#    self.card_verification = Base64.encode64(public_key.public_encrypt(self.card_verification))
#  end
  def Credential.cancel_subscription(subscription_id)
    aReq = ArbApi.new
    auth = MerchantAuthenticationType.new("88BUebw4Vy", "828yV4sW879mS8b7")
    xmlout = aReq.CancelSubscription(auth,subscription_id)
    xmlresp = HttpTransport.TransmitRequest(xmlout, 'https://api.authorize.net/xml/v1/request.api')
    apiresp = aReq.ProcessResponse(xmlresp)
    return apiresp
  end

  def link_transaction_logs
    transaction_log = TransactionLog.find_by_transaction_id(self.transaction_id)
    transaction_log.user_id = self.user.id
    transaction_log.save
  end

end
