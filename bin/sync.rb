require 'ruby_phpipam'
require 'rest-client'
require 'crack/xml'
require 'mixlib/cli'

class Sync
  include Mixlib::CLI

  option :panos_token,
         :long  => "--panos_token PANOS_TOKEN",
         :description => "PanOS token",
         required: true

  option :panos_url,
         :long  => "--panos_url PANOS_URL",
         :description => "PanOS url",
         required: true

  option :php_ipam_base_url,
         :short => "-b PHPIPAM_URL",
         :long  => "--php_ipam_base_url PHPIPAM_URL",
         :description => "PHPIPAM_URL url",
         required: true

  option :php_ipam_username,
         :long  => "--php_ipam_username PHPIPAM_USERNAME",
         :description => "PHPIPAM_USERNAME",
         required: true

  option :php_ipam_password,
         :long  => "--php_ipam_password PHPIPAM_PASSWORD",
         :description => "PHPIPAM_PASSWORD",
         required: true

  def ip_from_panos
    set_ag_response = RestClient::Request.execute(
      method: :get,
      verify_ssl: false,
      url: "#{config[:panos_url]}/api",
      headers: {
        params: {
          'key' => config[:panos_token],
          'type' => 'op',
          'cmd' => '<show><dhcp><server><lease>all</lease></server></dhcp></show>'
        }
      }
    )

    dag_hash = Crack::XML.parse(set_ag_response)
    dag_hash['response']['result']['interface'].map{|e| e['entry']}.flatten
  end

  def phpipam_login
    RubyPhpipam.configure do |c|
      c.base_url = config[:php_ipam_base_url]#"http://localhost/phpipam/api/123123"
      c.username = config[:php_ipam_username]
      c.password = config[:php_ipam_password]
    end

    RubyPhpipam.authenticate

    RubyPhpipam.auth.validate_token!
  end

  def sync
    phpipam_login

    RubyPhpipam::Section.get_all.each do |section|
      begin
        section.subnets.each do |subnet|

          subnet_addr = IPAddr.new(subnet.subnet)

          subnet_addr = subnet_addr.mask(subnet.mask)
          ip_from_panos.each do |h|

            ipaddr = IPAddr.new(h['ip'])
            if subnet_addr.include?(ipaddr)
              HTTParty.post(RubyPhpipam.gen_url("/addresses"),
                            headers: {token: RubyPhpipam.auth.token, 'Content-Type' => 'application/json'},
                            body: { ip: ipaddr.to_s, mac: h['mac'], 'subnetId' => subnet.id }.to_json ,
                            debug_output: $stdout

              )
            end
          end
        end
      rescue StandardError => e

      end
    end
  end

end

cli = Sync.new
cli.parse_options
cli.sync










