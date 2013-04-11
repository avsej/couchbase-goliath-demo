require 'em-synchrony'
require 'couchbase'
require 'goliath'
require 'grape'
require 'date'

class Chat < Grape::API

  format :json

  resource 'messages' do
    get do
      view = env.couchbase.design_docs["messages"].all(:include_docs => true)
      msgs = view.map do |r|
        {
          "id" => r.id,
          "key" => r.key,
          "value" => r.value,
          "cas" => r.meta["cas"],
          # "doc" => r.doc
        }
      end
      {"ok" => true, "messages" => msgs}
    end

    post do
      payload = {
        "timestamp" => DateTime.now.iso8601,
        "message" => params["message"]
      }
      id = env.couchbase.incr("msgid", :initial => 1)
      id = "msg:#{id}"
      cas = env.couchbase.set(id, payload)
      {"ok" => true, "id" => id, "cas" => cas}
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
