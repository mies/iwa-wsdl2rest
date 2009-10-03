require 'rubygems'
require 'sinatra'
require 'json'
require 'soap/wsdlDriver'

$URL = 'http://www.webservicex.net/geoipservice.asmx?wsdl'

wsdl = $URL
driver = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver

get '/' do
    #ip = request.env['HTTP_X_REAL_IP']
    #ipRange = request.env['REMOTE_ADDR']
    #ip = @env['HTTP_CLIENT_IP']
    #puts ip
    #ip2 = @env['HTTP_X_FORWARDED_FOR']
    #puts ip2
    ipArray = request.env['REMOTE_ADDR'].split(/,/)
    #ip = "192.434.54.34, 34.55.53.22"
    
    ip = ipArray[0]
    erb :index, :locals => {:ip => ip}
end

post '/location' do
    request = driver.getGeoIP('IPAddress' => params[:ip])
    result = request.getGeoIPResult()
    erb :location, :locals => {:ip => params[:ip], :country => result["CountryName"]}
end

post '/api/location.:format' do
    request = driver.getGeoIP('IPAddress' => params[:ip])
    result = request.getGeoIPResult()
    location = result["CountryName"]
    case params[:format]
    when 'xml'
        content_type :xml
        builder do |xml|
            xml.instruct!
            xml.countryname location
        end
    when 'json'
        content_type('application/json')
        {:CountryName => location}.to_json
    else
        content_type :json
        {:CountryName => location}.to_json
    end
end
