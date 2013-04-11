require 'em-synchrony'
require 'couchbase'
require 'goliath'
require 'grape'

class Chat < Grape::API

  format :json

  resource 'messages' do
    get do
      env.couchbase.get('foo')
    end

    post do
      payload = {"message" => params["message"]}
      id = env.couchbase.incr("msgid", :initial => 1)
      cas = env.couchbase.set("msg:#{id}", payload)
      {"ok" => true, "cas" => cas}
    end
  end

end

class App < Goliath::API
  def response(env)
    Chat.call(env)
  rescue => e
    [
      500,
      {'Content-Type' => 'application/json'},
      MultiJson.dump(:error => e, :stacktrace => e.backtrace)
    ]
  end
end
