require "sinatra"
require "json"
require "pry"

set :port, 8080

before do
 content_type :json 
 @request_payload = begin
    request.body.rewind
    params.merge!(JSON.parse request.body.read)
  rescue JSON::ParserError => e
    {}
  end
end

PATIENT_DATABASE = {}

post '/add' do
  patient = {
    "id" => last_patient_id + 1,
    "city" => @request_payload[:city],
    "state" => @request_payload[:state],
    "country" => @request_payload[:country],
    "status" => @request_payload[:status],
    "infected_date" => @request_payload[:infected_date],
    "updated_at" => Time.now,
  }
  PATIENT_DATABASE[patient["id"]] = patient
  patient.to_json
end

get '/ping' do
  'pong'
end

patch '/update/:id' do
  data = PATIENT_DATABASE[params[:id].to_i].merge!({
    "status" => @request_payload[:status],
    "updated_at" => Time.now,
  })
  data.to_json
end

get "/count" do
  count = 0
  PATIENT_DATABASE.each do |key, value|
    flag = true
    (params.keys & ["status", "country", "state", "city"]).each do |key|
      flag = false if value[key] != params[key]
    end
    count += 1 if flag
  end
  {count: count}.to_json
end

get '/get/:id' do
  PATIENT_DATABASE[params[:id].to_i].to_json
end

def last_patient_id
  PATIENT_DATABASE.keys.sort.last || 0
end
