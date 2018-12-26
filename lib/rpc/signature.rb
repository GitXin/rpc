module Rpc
  class Signature
    class << self
      def sign(payloads)
        sorted_payloads = Hash[payloads.sort]
        Digest::SHA256.hexdigest (sorted_payloads.map { |k, v| "#{k}=#{v}" }.join('&') + Rpc::DIGEST_KEY)
      end

      def verify_sign(payloads, verified_sign)
        sign(payloads) == verified_sign
      end
    end
  end
end
