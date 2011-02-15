# represents an admin log entry
class AdminLog
  include DataMapper::Resource

  property :id, Serial
  property :timestamp, Time, :default => proc { Time.now }, :required => true
  property :message, Text, :required => true

  belongs_to :agent
end
