# -*- coding: utf-8 -*-

module Delayer
  attr_reader :priority

  Bucket = Struct.new(:first, :last, :priority_of, :stashed) do
    def stash_size
      if stashed
        1 + stashed.stash_size
      else
        0
      end
    end
  end

  def self.included(klass)
    klass.class_eval do
      extend Extend
    end
  end

  def initialize(priority = self.class.instance_eval{ @default_priority }, *args)
    self.class.validate_priority priority
    @priority = priority
    @procedure = Procedure.new(self, &Proc.new)
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

  module Extend
    attr_accessor :expire
    attr_reader :exception

    def self.extended(klass)
      klass.class_eval do
        @busy = false
        @expire = 0
        @remain_hook = nil
        @exception = nil
        @remain_received = false
        @lock = Mutex.new
        @bucket = Bucket.new(nil, nil, {}, nil)
      end
    end

    # Run registered jobs.
    # ==== Args
    # [current_expire] expire for processing (secs, 0=unexpired)
    # ==== Return
    # self
    def run(current_expire = @expire)
      if 0 == current_expire
        run_once while not empty?
      else
        @end_time = Time.new.to_f + @expire
        run_once while not(empty?) and @end_time >= Time.new.to_f
        @end_time = nil
      end
      if @remain_hook
        @remain_received = !empty?
        @remain_hook.call if @remain_received  
      end
    rescue Exception => e
      @exception = e
      raise e
    end

    def expire?
      if defined?(@end_time) and @end_time
        @end_time < Time.new.to_f
      else
        false
      end
    end

    # Run a job and forward pointer.
    # ==== Return
    # self
    def run_once
      if @bucket.first
        @busy = true
        procedure = forward
        procedure = forward while @bucket.first and procedure.canceled?
        procedure.run unless procedure.canceled?
      end
    ensure
      @busy = false
    end

    # Return if some jobs processing now.
    # ==== Args
    # [args] 
    # ==== Return
    # true if Delayer processing job
    def busy?
      @busy
    end

    # Return true if no jobs has.
    # ==== Return
    # true if no jobs has.
    def empty?
      !@bucket.first
    end

    # Return remain jobs quantity.
    # ==== Return
    # Count of remain jobs
    def size(node = @bucket.first)
      if node
        1 + size(node.next)
      else
        0
      end
    end

    # register new job.
    # ==== Args
    # [procedure] job(Delayer::Procedure)
    # ==== Return
    # self
    def register(procedure)
      priority = procedure.delayer.priority
      lock.synchronize do
        last_pointer = get_prev_point(priority)
        if last_pointer
          @bucket.priority_of[priority] = last_pointer.break procedure
        else
          procedure.next = @bucket.first
          @bucket.priority_of[priority] = @bucket.first = procedure
        end
        if @bucket.last
          @bucket.last = @bucket.priority_of[priority]
        end
        if @remain_hook and not @remain_received
          @remain_received = true
          @remain_hook.call
        end
      end
      self
    end

    def register_remain_hook
      @remain_hook = Proc.new
    end

    def get_prev_point(priority)
      if @bucket.priority_of[priority]
        @bucket.priority_of[priority]
      else
        next_index = @priorities.index(priority) - 1
        get_prev_point @priorities[next_index] if 0 <= next_index
      end
    end

    def validate_priority(symbol)
      unless @priorities.include? symbol
        raise Delayer::InvalidPriorityError, "undefined priority '#{symbol}'"
      end
    end

    # Delayerの再帰レベルをインクリメントする。
    # このメソッドが呼ばれたら、その時存在するジョブは退避され、recursive_pop!が呼ばれるまで実行されない。
    def recursive_push!
      @bucket = Bucket.new(nil, nil, {}, @bucket)
      self
    end

    # Delayerの再帰レベルをデクリメントする。
    # このメソッドを呼ぶ前に、現在のレベルに存在するすべてのジョブを実行し、Delayer#empty?がtrueを返すような状態になっている必要がある。
    # ==== Raises
    # [Delayer::NoLowerLevelError] recursive_push!が呼ばれていない時
    # [Delayer::RemainJobsError] ジョブが残っているのにこのメソッドを呼んだ時
    def recursive_pop!
      raise Delayer::NoLowerLevelError, 'recursive_pop! called in level 0.' if !@bucket.stashed
      raise Delayer::RemainJobsError, 'Current level has remain jobs. It must be empty current level jobs in call this method.' if !self.empty?
      @bucket = @bucket.stashed
    end

    # 現在のDelayer再帰レベルを返す。
    def recursive_level
      @bucket.stash_size
    end

    private

    def forward
      lock.synchronize do
        prev = @bucket.first
        @bucket.first = @bucket.first.next
        @bucket.last = nil unless @bucket.first
        @bucket.priority_of.each do |priority, pointer|
          @bucket.priority_of[priority] = @bucket.first if prev == pointer
        end
        prev.next = nil
        prev
      end
    end

    def lock
      @lock
    end
  end
end
