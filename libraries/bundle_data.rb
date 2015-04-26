require_relative 'curl'
require 'json'

module AEM
  class Bundle
    class Data
      include Curl

      attr_reader :content

      def initialize(aem_uri, symbolic_name)
        aem_uri.path += "/system/console/bundles/#{symbolic_name}.json"
        curl(aem_uri) do |cu|
          cu.on_success do |c, _|
            @content =
              JSON.parse(c.body_str)['data']
                .select { |h| h['symbolicName'] == symbolic_name }
                .first
            end
          cu.perform
        end
      end

      def found?
        !!@content
      end

      def state
        return nil unless found?

        content['state']
      end

      def version
        return nil unless found?

        content['state']
      end
    end
  end
end
