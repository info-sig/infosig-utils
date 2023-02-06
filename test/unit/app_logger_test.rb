require 'test_helpers'

class AppLoggerTest < UnitTest

  def test_filtered_log_level_array_size
    assert_raises ArgumentError do |exception|
      AppLogger.filtered_log_level([:one_element])
      assert_equal exception, 'Array must contain exactly 2 elements'
    end
  end

  def test_filtered_log_level_error_element
    assert_raises ArgumentError do |exception|
      AppLogger.filtered_log_level([:weird_error, 'Error message'])
      assert_equal exception, "First element must be one of the following: #{LOG_LEVELS.keys}"
    end
  end

  def test_filtered_log_level_wrong_message
    output, _ = capture_io do
      AppLogger.filtered_log_level([:error, 'Test message']) do
        begin
          raise ArgumentError.new 'Test'
        rescue Exception => e
          mock_backtrace e, :error
        end
      end
    end

    assert_equal true, output.include?("[error] ArgumentError Test\n")
  end

  def test_filtered_log_level_wrong_severity
    output, _ = capture_io do
      AppLogger.filtered_log_level([:error, 'Test message']) do
        begin
          raise ArgumentError.new 'Test message'
        rescue Exception => e
          mock_backtrace e, :warn
        end
      end
    end

    assert_equal true, output.include?("[warn] ArgumentError Test message\n")
  end


private

  def mock_backtrace e, severity
    backtrace = e.backtrace

    backtrace.map! do |line|
      line
    end

    output = "#{e.class} #{e.message}\n"
    output += backtrace.join("\n")
    AppLogger.send(severity, output)
  end
end
