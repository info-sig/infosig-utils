require 'test_helpers'

class AppLoggerTest < UnitTest

  def test_filtered_log_level_only_one_element
    exception = assert_raises ArgumentError do
      AppLogger.filtered_log_level(:error)
    end
    assert_equal "There must be at least 2 elements present", exception.message
  end

  def test_filtered_log_level_text_error
    exception = assert_raises ArgumentError do
      AppLogger.filtered_log_level(:error, :no_string_message)
    end
    assert_equal "Last element must be a string message", exception.message
  end

  def test_filtered_log_level_wrong_error_element
    exception = assert_raises ArgumentError do
      AppLogger.filtered_log_level(:one_element, 'Some error message')
    end
    assert_equal "First element must be one of the following: #{AppLogger::LOG_LEVELS.keys}", exception.message
  end

  def test_filtered_log_level_wrong_message
    output, _ = capture_io do
      AppLogger.filtered_log_level(:error, 'Wrong message') do
        begin
          raise ArgumentError.new 'Actual message'
        rescue Exception => e
          mock_backtrace e, :error
        end
      end
    end

    assert_equal true, output.include?("Actual message")
  end

  def test_filtered_log_level_wrong_severity
    output, _ = capture_io do
      AppLogger.filtered_log_level(:error, 'Test message') do
        begin
          raise ArgumentError.new 'Test message'
        rescue Exception => e
          mock_backtrace e, :warn
        end
      end
    end

    assert_equal true, output.include?("[warn] ArgumentError Test message")
  end

  def test_filtered_log_level_with_multiple_correct_severities
    output, _ = capture_io do
      AppLogger.filtered_log_level(:error, :debug, 'Test message') do
        begin
          raise ArgumentError.new 'Test message'
        rescue Exception => e
          mock_backtrace e, :debug
          mock_backtrace e, :error
        end
      end
    end

    assert_equal true, output.include?("")
  end

  def test_filtered_log_level_with_multiple_severities_incorrect
    output, _ = capture_io do
      AppLogger.filtered_log_level(:error, :debug, 'Test message') do
        begin
          raise ArgumentError.new 'Test message'
        rescue Exception => e
          mock_backtrace e, :info
          mock_backtrace e, :error
        end
      end
    end

    assert_equal true, output.include?("[info] ArgumentError Test message")
  end


  def test_filtered_log_level_change_log_level_to_array
    output, _ = capture_io do
      AppLogger.stub(:log_level, :error) do
        AppLogger.filtered_log_level(:error, 'Test message') do
          begin
            raise ArgumentError.new 'Test message'
          rescue Exception => e
            mock_backtrace e, :error
          end
        end
      end
    end

    assert_equal true, output.include?("")
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
