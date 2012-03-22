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
        if i
          i.gsub!(/https?:\/\//, '') # remove http:// or https://
          i.gsub!(/\..*/, '') # remove .myshopify.com
        end
        i
      end

      def get_identifier
        f = OmniAuth::Form.new(:title => 'Shopify Authentication')
        f.label_field('The URL of the Shop', options.identifier_param)
        f.input_field('url', options.identifier_param)
        f.to_response
      end

      def create_permission_url
        "http://#{identifier}.myshopify.com/admin/api/auth?api_key=#{options[:api_key]}"
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

      uid{ identifier }
      info{ {
        :name => identifier,
        :urls => {:site => "https://#{identifier}.myshopify.com/admin"}
      } }
      credentials{ { # basic auth
        :username => options.api_key,
        :password => Digest::MD5.hexdigest(options.secret + self.token)
      } }
    end
  end
end
