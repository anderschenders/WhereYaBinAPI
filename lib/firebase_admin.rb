
module FirebaseAdmin
  class PublicKeys
    URL = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com'
    EXPIRES_HEADER = 'expires'

    attr_reader :response, :data

    delegate :keys, :values, to: :data

    def initialize
      @response = fetch
    end

    def valid?
      Time.now.utc < time_to_expire
    end

    def data
      @response.as_json
    end

    private

    def time_to_expire
      @time_to_expire ||= Time.parse(
        response.headers[EXPIRES_HEADER]
      )
    end

    def fetch
      HTTParty.get(URL)
    end
  end

  class IDTokenVerifier
    JWT_OPTIONS = { algorithm: 'RS256', verify_iat: true }

    attr_reader :certificates

    def initialize(public_keys)
      @public_keys  = public_keys
      @certificates = map_certificates
    end

    def verify(id_token)
      result = nil

      certificates.each do |x509|
        result = decode_jwt(id_token, x509)

        break if result
      end

      result
    end

    private

    def decode_jwt(id_token, x509)
      JWT.decode(id_token, x509.public_key, true, JWT_OPTIONS)
    rescue JWT::VerificationError
      nil
    end

    def map_certificates
      @public_keys.values.map do |credential|
        OpenSSL::X509::Certificate.new(credential)
      end
    end
  end

  class Auth
    include Singleton

    def initialize
      refresh
    end

    def public_keys
      resolve { @public_keys }
    end

    def verify_id_token(id_token)
      result = resolve { @id_token_verifier.verify(id_token) }

      if result
        payload, header = result

        [ OpenStruct.new(payload), OpenStruct.new(header) ]
      end
    end

    class << self
      delegate :verify_id_token, :public_keys, to: :instance
    end

    private

    def refresh
      @public_keys = PublicKeys.new
      @id_token_verifier = IDTokenVerifier.new(@public_keys)
    end

    def resolve
      refresh unless @public_keys.valid?

      yield
    end
  end
end
