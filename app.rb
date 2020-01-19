require 'json'
require 'sinatra'
require 'sinatra/activerecord'
require './config/database'

Dir['./app/models/**/*.rb'].each { |file| require file }
Dir['./app/services/**/*.rb'].each { |file| require file }
Dir['./app/helpers/**/*.rb'].each { |file| require file }

class App < Sinatra::Base
  get '/' do
    'Hello World!'
  end

  post '/webhook' do
    request.body.rewind
    result = JSON.parse(request.body.read)['queryResult']
    response = InterpreterService.call(
      result['action'],
      result['parameters'],
      result['languageCode']
    )

    content_type :json, charset: 'utf-8'
    {
      "fulfillmentText": response,
      "payload": {
        "telegram": {
          "text": response,
          "parse_mode": "MarkdownV2"
        }
      }
    }.to_json
  end
end
