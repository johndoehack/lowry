require 'sinatra'
require 'whois'
require 'json'

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
  get '/whois/:host' do
    host = "#{params[:host]}"
    begin
      w = Whois.whois(host)
      finish_whois(host, w)
    rescue Whois::ServerNotFound => e
      status 503
    end

  end

  get '/*' do
    halt 404
  end
end
