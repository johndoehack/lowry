require 'sinatra'
require 'whois'
require 'json'
require 'nmap/program'
require 'nmap/xml'

def command?(command)
  system("which #{command} > /dev/null 2>&1")
end

def finish_whois(host, w)
  resp = {
    "hostname"=>host,
    "registered"=>w.registered?,
    "available"=>w.available?
  }
  if w.registered?
    resp["created_on"] = w.created_on
    resp["updated_on"] = w.updated_on
    resp["expires_on"] = w.expires_on
    resp["status"] = w.status
    resp["referral_url"] = w.referral_url
    resp["referral_whois"] = w.referral_whois
    resp["disclaimer"] = w.disclaimer
  end

  status 200
  headers "Content-Type" => "application/json"
  body JSON.dump(resp)
end
class Lowry < Sinatra::Base
  get '/:host/whois' do
    host = params[:host]
    begin
      w = Whois.whois(host)
      finish_whois(host, w)
    rescue Whois::ServerNotFound => e
      status 503
    end

  end
  get '/:host/nmap' do
    host = params[:host]
    if ! command?("nmap")
      status 503
    else
      Nmap::Program.scan do |nmap|
        nmap.xml = 'scan.xml'
        nmap.ports = [22,23,80,443]
        nmap.targets = host
      end
      resp = {
        "hostname"=>host
      }
      xml = Nmap::XML.new('scan.xml')
      nhost = xml.hosts[0]
      puts xml.hosts.length
      resp["ip"] = nhost.ip
      nhost.each_port do |port|
        resp["#{port.number}"] = port.state
      end
      status 200
      headers "Content-Type" => "application/json"
      body JSON.dump(resp)
    end
  end
  get '/*' do
    halt 404
  end
end
