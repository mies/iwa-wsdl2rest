require 'rubygems'
require 'sinatra'
require 'json'
require 'soap/wsdlDriver'

$URL = 'http://www.webservicex.net/geoipservice.asmx?wsdl'

wsdl = $URL
driver = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver

get '/' do
    ip = @env['REMOTE_ADDR']
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
