# -*- coding: utf-8 -*-

module Delayer
  class << self
    attr_accessor :default

    def included(klass)
      klass.extend Extend
    end

    # Generate new Delayer class.
    # ==== Args
    # [options]
    #   Hash
    #   expire :: processing expire (secs, 0=unlimited)
    #   priority :: priorities
    #   default :: default priotity
    # ==== Return
    # A new class
    def generate_class(options = {})
      if options[:priority]
        Class.new do
          include Priority
          @expire = options[:expire] || 0
          @priorities = options[:priority]
          @default_priority = options[:default]
        end
      else
        Class.new do
          include ::Delayer
          @expire = options[:expire] || 0
        end
      end
    end

    def method_missing(*args, &proc)
      (@default ||= generate_class).__send__(*args, &proc)
    end
  end

  def initialize(*args, &proc)
    super
    @procedure = Procedure.new(self, &Proc.new(&proc))
  end

  # Cancel this job
  # ==== Exception
  # Delayer::AlreadyExecutedError :: if already called run()
  # ==== Return
  # self
  def cancel
    @procedure.cancel
    self
  end
end
