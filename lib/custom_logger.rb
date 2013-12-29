class CustomLogger < Logger
#  def initialize
#  end
  def format_message(severity, timestamp, progname, msg)
    "#{severity.ljust(5)} #{timestamp.to_formatted_s(:db)} >> #{msg}\n"
#    "#{msg}\n"
  end
end

logfile = File.open(RAILS_ROOT + '/log/custom.log', 'a')  #create log file
logfile.sync = true  #automatically flushes data to file

CUSTOM_LOGGER = CustomLogger.new(logfile)  #constant accessible anywhere

