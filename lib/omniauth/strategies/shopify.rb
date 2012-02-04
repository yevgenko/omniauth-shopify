require 'omniauth'

module OmniAuth
  module Strategies
    class Shopify
      include OmniAuth::Strategy

      args [:api_key, :secret]

      option :api_key, nil
      option :secret, nil
      option :identifier, nil
      option :identifier_param, 'shop'

      attr_accessor :token

      def identifier
        i = options.identifier || request.params[options.identifier_param.to_s]
        i = nil if i == ''
        i
      end

      def get_identifier
        f = OmniAuth::Form.new(:title => 'Shopify Authentication')
        f.label_field('The URL of the Shop', options.identifier_param)
        f.input_field('url', options.identifier_param)
        f.to_response
      end

      def create_permission_url
        url = identifier
        url.gsub!(/https?:\/\//, '')                            # remove http:// or https://
        url.concat(".myshopify.com") unless url.include?('.')   # extend url to myshopify.com if no host is given

        "http://#{url}/admin/api/auth?api_key=#{options[:api_key]}"
      end

      def start
        redirect create_permission_url
      end

      def validate_signature(params)
        signature = params.delete('signature')
        sorted_params = params.collect{|k,v|"#{k}=#{v}"}.sort.join
        Digest::MD5.hexdigest(options.secret + sorted_params) == signature
      end

      ##
      # Authentication Lifecycle
      ##

      def request_phase
        identifier ? start : get_identifier
      end

      def callback_phase
        params = request.params
        return fail!(:invalid_response) unless validate_signature(params) && params['timestamp'].to_i > (Time.now - 24 * 3600).utc.to_i
        self.token = params['t']
        super
      end

      uid{ request.params[options.identifier_param.to_s] }
      info{ {:name => request.params[options.identifier_param.to_s]} }
      credentials{ {:token => self.token} }
    end
  end
end
