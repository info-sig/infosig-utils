class SingleFileLogger
  include Functional

  def call domain
    log_file_name = "log/#{domain}-#{Time.now.strftime("%Y%m%d-%H%M%S")}-#{SecureRandom.hex(6)}.log"
    AppLogger.info "[SingleFileLogger] logging to #{log_file_name} at #{caller.first(3)}"
    rv = nil

    File.open(log_file_name, 'w')  do |file|
      yielded_logger = LineLogger.new(file)
      rv = yield(yielded_logger)
    end

    rv
  end


  private

  class LineLogger < Struct.new(:log_file)
    include Functional
    def call string
      log_file.write string+"\n"
      nil
    end
  end

end