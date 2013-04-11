config['couchbase'] = EventMachine::Synchrony::ConnectionPool.new(:size => 5) do
  Couchbase::Bucket.new(:engine => :eventmachine)
end
