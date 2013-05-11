require 'rubygems'
require 'bundler/setup'

require 'eventbrite-client'
require 'digest/md5'
require './env'

eb_auth_tokens = {
  app_key: APP_KEY,
  user_key: USER_KEY
}

eb_client = EventbriteClient.new(eb_auth_tokens)

# response = eb_client.user_list_events()
response = eb_client.event_list_attendees({id: 6377121141})

File.open("_includes/attendees.html", 'w') {|f|

  response["attendees"].sort_by{|hsh| hsh["attendee"]["created"] }.each{|hsh|
    attendee_hsh = hsh["attendee"]

    name = [attendee_hsh["first_name"], attendee_hsh["last_name"]].compact.join(" ")

    tags = attendee_hsh["answers"].find_all{|x| x["answer"]["question_id"] == 3959643}.first["answer"]["answer_text"].split(",")
    email = attendee_hsh["email"]
    hash = Digest::MD5.hexdigest(email)
    gravatar_url = "http://www.gravatar.com/avatar/#{hash}"

    str = "<tr>\n"
    str << "  <td><img src='#{gravatar_url}'</td>\n"
    str << "  <td>#{name}</td>\n"
    str << "  <td>#{tags.join(", ")}</td>\n"
    str << "</tr>\n"
    f.write(str)
  }

}
