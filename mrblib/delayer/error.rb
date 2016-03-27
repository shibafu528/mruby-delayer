# -*- coding: utf-8 -*-

module Delayer
  class Error < ::StandardError; end
  class TooLate < Error; end
  class AlreadyExecutedError < TooLate; end
  class AlreadyCanceledError < TooLate; end
  class AlreadyRunningError < TooLate; end
  class InvalidPriorityError < Error; end
  def self.StateError(state)
    case state
    when :run
      AlreadyRunningError
    when :done
      AlreadyExecutedError
    when :cancel
      AlreadyCanceledError
    end
  end
end
