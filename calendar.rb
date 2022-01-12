require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'google calendar api test'
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = 'calendar-ruby-quickstart.yaml'
SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

# Check provided date
begin
  date = Date.parse(ARGV[0]).to_time
  ARGV.clear
rescue
  puts 'No date provided or wrong format'
  exit
end

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(
    client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(
      base_url: OOB_URI)
    puts "Open the following URL in the browser and enter the " +
         "resulting code after authorization"
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI)
  end
  credentials
end

# Initialize the API
service = Google::Apis::CalendarV3::CalendarService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

# Fetch events for the user
calendar_id = 'primary'
response = service.list_events(calendar_id,
                               single_events: true,
                               order_by: 'startTime',
                               time_min: date.iso8601,
                               time_max: (date + 86399).iso8601)

puts "Events for #{date.strftime('%F')}:"
puts "No events for this date" if response.items.empty?
response.items.each do |event|
  start = event.start.date_time&.strftime('%H:%M') || 'N/A'
  attendees = event.attendees.to_a.map(&:email)
  attendees = attendees.any? ? attendees.join(', ') : 'N/A'
  puts "#{start} - #{attendees} - #{event.summary})"
end
