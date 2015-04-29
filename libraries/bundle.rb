require_relative 'curl'
require 'uri'
require 'timeout'

module AEM
  class Bundle
    STATES = %w(Active Fragment).freeze

    include Curl

    attr_accessor :bundle_path
    attr_reader :symbolic_name, :version, :aem_uri

    def initialize(symbolic_name: nil, version: nil, bundle_path: nil, aem_uri: 'http://admin:admin@localhost:4502')
      fail 'symbolic_name missing' unless symbolic_name
      @symbolic_name = symbolic_name
      @version = version
      @bundle_path = bundle_path
      @aem_uri = URI(aem_uri)
    end

    def install!
      fail 'bundle_path missing' unless bundle_path

      uri = aem_uri.dup
      uri.path += '/system/console/bundles'
      curl(uri) do |cu|
        cu.multipart_form_post = true
        fields = [
          ::Curl::PostField.content('action', 'install'),
          ::Curl::PostField.content('bundlestartlevel', '20'),
          ::Curl::PostField.file('bundlefile', bundle_path)
        ]
        cu.http_post(*fields)
      end

      installed?
    end

    def install
      return true if installed?
      install!
    end

    def installed?
      data = Data.new(aem_uri, symbolic_name)
      return false unless data.found?

      if version
        data.version == version
      else
        true
      end
    end

    def uninstall!
      uri = aem_uri.dup
      uri.path += "/system/console/bundles/#{symbolic_name}"
      curl(uri) do |cu|
        cu.http_post(::Curl::PostField.content('action', 'uninstall'))
      end

      uninstalled?
    end

    def uninstall
      return true unless installed?
      uninstall!
    end

    def uninstalled?
      !installed?
    end

    def start!
      uri = aem_uri.dup
      uri.path += "/system/console/bundles/#{symbolic_name}"
      curl(uri) do |cu|
        cu.http_post(::Curl::PostField.content('action', 'start'))
      end

      started?
    end

    def started?
      data = Data.new(aem_uri, symbolic_name)

      data.found? && STATES.include?(data.state)
    end

    def stop!
      uri = aem_uri.dup
      uri.path += "/system/console/bundles/#{symbolic_name}"
      curl(uri) do |cu|
        cu.http_post(::Curl::PostField.content('action', 'stop'))
      end

      stopped?
    end

    def stopped?
      !started?
    end

    private

    def wait(&block)
      Timeout::timeout(600) do
        loop do
          break if block.call
        end
      end
    end
  end
end
