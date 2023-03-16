require "test_helpers"

class AppLoggerTest < UnitTest

  def test_app_logger_logs_to_file
    time_stamp = "#{Time.now}".gsub(' ', '_')
    filename = "log_#{time_stamp}.log"
    log = AppLogger.new file: filename
    log.error "Logging to file"
    log.close

    f = File.open(filename)
    first_line = f.readline
    f.close
    assert_equal "[error] Logging to file\n", first_line, 'expected to see "[error] Logging to file\n"'
  end

end