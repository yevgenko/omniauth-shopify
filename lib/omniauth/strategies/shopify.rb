require 'omniauth'

module OmniAuth
  module Strategies
    class Shopify
      include OmniAuth::Strategy

      args [:api_key, :secret, :scopes]

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
        f = OmniAuth::Form.new(:title => 'Connect your Shopify Shop')
        f.label_field('Your Shop URL', options.identifier_param)
        f.input_field('url', options.identifier_param)
        f.to_response
      end

      def base_url
        "https://#{identifier}.myshopify.com"
      end

      def permission_url
        base_url + "/admin/oauth/authorize?client_id=#{options[:api_key]}&scope=#{options[:scopes].join(',')}"
      end

      def token_url
        base_url + '/admin/oauth/access_token'
      end

      def start
        redirect permission_url
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

        self.token = get_token(params['code'])
        super
      end

      def get_token(code)
        params = { 
          :client_id     => options[:api_key], 
          :client_secret => options[:secret], 
          :code          => code 
        }

        response = Faraday.post(token_url, params)

        if response.status == 200
          token = JSON.parse(response.body)['access_token']
        else
          raise RuntimeError, response.body
        end
      end

      uid{ identifier }
      info{ {
        :name => identifier,
        :urls => {:site => base_url}
      } }
      credentials{ { # basic auth
        :token => self.token
      } }
    end
  end
end
