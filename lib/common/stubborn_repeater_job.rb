class StubbornRepeaterJob
  include Functional
  include Backgroundable

  class IllegalDecline < RuntimeError; end

  def call api_class, *args
    rv = api_class.constantize.call(*args)
    unless rv.dig(:response, :status) == 'approved'
      InfoSig.log.error rv
      raise IllegalDecline.new("#{api_class} call to should have been approved!")
    end
  end
end