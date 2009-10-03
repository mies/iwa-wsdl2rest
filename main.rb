require 'rubygems'
require 'sinatra'
require 'json'
require 'soap/wsdlDriver'

$URL = 'http://www.webservicex.net/geoipservice.asmx?wsdl'

wsdl = $URL
driver = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver

get '/' do
    #ip = request.env['REMOTE_ADDR']
    # A split is used as heroku returns multiple IP addresses
    # for localhosthost use the statement above.

    ipArray = request.env['REMOTE_ADDR'].split(/,/)
    ip = ipArray[0]
    erb :index, :locals => {:ip => ip}
end

post '/location' do
    request = driver.getGeoIP('IPAddress' => params[:ip])
    result = request.getGeoIPResult()
    erb :location, :locals => {:ip => params[:ip], :country => result["CountryName"]}
end

#if using curl or a webrequest with paramater, issue a GET instead of POST
#in the function below

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
