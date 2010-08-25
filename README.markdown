# Cybozu2Gcal

This script is a small helper to liberate your Cybozu schedule by importing it to Google Calendar.
It is by no means intended to be a fully supported package, rather as a quick helper - the whole
problem probably doesn't deserver much more than this script until Cybozu will finally start allowing 
synchronization. In the meantime, you can use this script.

# Setup

You will need ruby with the gcal4ruby gem. Install this gem with the command

`gem install gcal4ruby`

Check the contents of the repository out and review check_calendar.rb It is very important that you
don't just run it without understanding what it does. In general, if you don't know why you should
use this script, you probably shouldn't use it.

## Parameters

+ *UID* : This is your User Id on the Cybozu system. The easiest way to find it out is to look on the login page
+ *cybozu_password* : This is your password to the Cybozu system. Keep this script secret and not accessible to others.
+ *cybozu_url* : This is the top URL of your cybozu installation, or in other words the hostname for the login page.
+ *cybozu_path* : This is the path to the ag.cgi page. Mind the leading /
+ *google_account* : This is the email address you use to log in to your google account
+ *google_password* : The password to your google account
+ *google_calendar* : The name of the calendar you wish your Cybozu events to be added to. This must exist and a separate calendar is recommended
+ *google_author* : An optional parameter to set the author of the event in google calendar. The original cybozu author and members are not synced
+ *google_where* : An optional parameter to set the location of the event in google calendar. The original cybozu location is not synced.

## Sample cron job

  ``0 * * * * /home/zaki/cybozu2gcal/check_calendar.rb 2>&1 /dev/null``
  
# License

  DO WHAT YOU WANT TO PUBLIC LICENSE 
  
  Copyright (C) 2010 Zoltan Dezso <dezso.zoltan@gmail.com> 

  Everyone is permitted to copy and distribute verbatim or modified 
  copies of this license document, and changing it is allowed as long 
  as the name is changed.

  DO WHAT YOU WANT TO PUBLIC LICENSE 
  TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION 

  0. You just DO WHAT YOU WANT TO. (But it's not my fault)
  
  This program is free software. It comes without any warranty, to
  the extent permitted by applicable law. You can redistribute it
  and/or modify it under the terms of the Do What You Want
  To Public License, Version 2.
