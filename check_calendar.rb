#!/usr/bin/ruby
 
require 'iconv'
require 'net/https'
require 'rubygems'
require 'date'
require 'gcal4ruby'
include GCal4Ruby
 
######### SETUP #########
UID             = '000'                 # find this on the login page
cybozu_password = 'changeme'            # this is your password
cybozu_url      = 'path.to.cybozu'      # this is the url to your cybozu install (without http://)
cybozu_path     = '/cgi-bin/xc0000000000/ag.cgi' # change this to represent the real path
google_account  = 'user.name@gmail.com'
google_password = 'changeme'
google_calendar = 'TestCal'             # the name of the calendar you want to push events to
google_author   = 'Me'                  # set this if you want to change appointment author in gcal
google_where    = 'Office'
#########  END  #########
 
# Get rid of useless warning in HTTPS
class Net::HTTP
  alias_method :old_initialize, :initialize
  def initialize(*args)
    old_initialize(*args)
    @ssl_context = OpenSSL::SSL::SSLContext.new
    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end

def save_event(cal,ev,event=nil)
  event = Event.new(cal) if event.nil?
  event.title = Iconv.conv('utf8','sjis',ev[:title]) + " (EID=#{ev[:content]})"

  ev[:startTime] = sanitize_time(ev[:startTime])
  ev[:endTime] = sanitize_time(ev[:endTime])

  event.start = Time.parse(ev[:startTime])
  event.end = Time.parse(ev[:endTime])
  event.where = ev[:where]
  event.save
end
 
def sanitize_time(datetime)
  return '' if datetime.nil?
  return datetime.gsub(/24\:00/, '23:59')
end
 
 
conn = Net::HTTP.new(cybozu_url,443)
conn.use_ssl = true
 
req = Net::HTTP::Post.new(cybozu_path)
req.set_form_data({
                    'csrf_ticket'=>'',
                    '_System'=>'login',
                    '_Login'=>'1',
                    'LoginMethod'=>'0',
                    '_ID'=>UID,
                    'password'=>cybozu_password,
                    'page'=>'ScheduleUserMonth',
                    'CP'=>'',
                    'SP'=>''
})
res = conn.start {|http| http.request(req)}
events = []
 
filter = /\<a class="event" href="ag\.cgi\?page=ScheduleView\&UID=#{UID}\&GID=[0-9]+\&Date=da\.([0-9]+)\.([0-9]+)\.([0-9]+)\&BDate=da\.([0-9]+)\.([0-9]+)\.([0-9]+)\&sEID=([0-9]+)\&CP=sm" title="([^\"]*)"\>/
 
res.body.gsub(filter) {|match|
  subj  = $8
  contents = $7
  fromd = "#{$4}-#{format('%02d',$5)}-#{format('%02d',$6)}"
  endd  = "#{$1}-#{format('%02d',$2)}-#{format('%02d',$3)}"
  from  = "00:00.000"
  to    = "23:59.000"
  title = ""
  if (subj =~ /([0-9]+):([0-9]+)-([0-9]+):([0-9]+)\&nbsp\;(.*)/)
    from = "#{$1}:#{format('%02d',$2)}.000"
    to   = "#{$3}:#{format('%02d',$4)}.000"
    title = $5
  elsif (subj =~ /([0-9]+)\/([0-9]+)-([0-9]+):([0-9]+)\&nbsp\;(.*)/)
	to   = "#{$3}:#{format('%02d',$4)}.000"
	title = $5
  elsif (subj =~ /([0-9]+):([0-9]+)-([0-9]+)\/([0-9]+)\&nbsp\;(.*)/)
	from = "#{$1}:#{format('%02d',$2)}.000"
	title = $5
  end

  events << {
            :title     => title,
            :content   => contents,
            :author    => google_author,
            :email     => google_account,
            :where     => google_where, 
            :startTime => "#{fromd}T#{from}Z",
            :endTime   => "#{endd}T#{to}Z"
            }
}
 
service = Service.new
service.authenticate(google_account, google_password)
cal = Calendar.find(service, google_calendar)[0]
 
events.each {|ev|
  events = Event.find(cal, "(EID=#{ev[:content]})")
  if (events.nil? || events.length == 0 )
    save_event(cal,ev)
  else
    updated = false
    events.each {|event|
      if (event.start == Time.parse(sanitize_time(ev[:startTime])) && event.end == Time.parse(sanitize_time(ev[:endTime])))
        save_event(cal,ev,event)
        updated = true
      end
    }
    unless updated
      save_event(cal,ev)
    end
  end
}
