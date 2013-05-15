require 'rubygems'
require 'bundler/setup'

require 'eventbrite-client'
require 'digest/md5'
require './env'

def output(position, gravatar_hash, name, tags)
  gravatar_url = "http://www.gravatar.com/avatar/#{gravatar_hash}.png?size=48"

  str = "<tr>\n"
  str << "  <td style='text-align:center;'>#{position}</td>\n"
  str << "  <td><img src='#{gravatar_url}'</td>\n"
  str << "  <td>#{name}</td>\n"
  str << "  <td>#{tags.join(", ")}</td>\n"
  str << "</tr>\n"
end

eb_auth_tokens = {
  app_key: APP_KEY,
  user_key: USER_KEY
}

eb_client = EventbriteClient.new(eb_auth_tokens)

# response = eb_client.user_list_events()
response = eb_client.event_list_attendees({id: 6377121141})

pos = 0

File.open("_includes/attendees.html", 'w') {|f|

  f.write(output("organizer", "139b66112d2e2b4efafac2aefed01c2f", "Yann Klis", %w(ruby rails nodejs)))
  f.write(output("organizer", "1c72bce95176cfcb37de816f5be59dd5", "Yannick Jost", %w(robot embedded python)))

  response["attendees"].sort_by{|hsh| hsh["attendee"]["created"] }.each{|hsh|
    attendee_hsh = hsh["attendee"]

    name = [attendee_hsh["first_name"], attendee_hsh["last_name"]].compact.join(" ")

    tags = attendee_hsh["answers"].find_all{|x| x["answer"]["question_id"] == 3959643}.first["answer"]["answer_text"].split(",")
    email = attendee_hsh["email"]
    gravatar_hash = Digest::MD5.hexdigest(email)

    pos+=1

    f.write(output("#{pos}.", gravatar_hash, name, tags))
  }

}
