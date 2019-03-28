if ENV['PARALLEL']

  $PARALLEL_EXECUTION = true

  if ENV['PARALLEL'].to_i > 0
    ENV['NCPU'] = ENV['PARALLEL']
  else
    ENV['NCPU'] = '8'
  end

  require 'minitest/parallel_fork'

  Minitest.before_parallel_fork do
    DB.disconnect
  end

  Minitest.after_parallel_fork do |i|
    DB.opts[:database] += "_" + (i+1).to_s
  end

end