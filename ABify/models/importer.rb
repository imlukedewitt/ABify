# frozen_string_literal: true

require 'time'
require 'typhoeus'
require 'securerandom'
require_relative 'hydra_logger'
require_relative '../workflows/workflow'

# An Importer runs a workflow on a set of data
# The config object is passed to each step to help build requests
class Importer
  attr_reader :status, :id, :data

  def initialize(config, workflow, data, keystore)
    @config = config
    @id = generate_id
    config.row_count = data.rows.count
    config.logger = HydraLogger.new("log/#{@id}.log")
    @workflow = workflow
    @data = data
    @hydra = Typhoeus::Hydra.new(max_concurrency: 50)
    @status = 'not started'
    @created_at = Time.now
    @keystore = keystore

    keystore.set(@id, summary)
  end

  def start
    @status = 'running'
    puts 'starting import'
    first_step, *next_steps = @workflow.steps
    @stop_update_thread = false
    update_thread = start_keystore_update_thread

    @data.rows.each do |row|
      first_step&.enqueue(row, @hydra, next_steps, @config)
    end

    @hydra.run
    @status = 'complete'
    @stop_update_thread = true
    update_thread.join
    @completed_at = Time.now
    @keystore.set(@id, summary)
    puts "\n\ngreat job"
  end

  def summary(data: true)
    end_time = @completed_at || Time.now
    run_time = run_duration(@created_at, end_time)

    {
      id: @id,
      status: @status,
      created_at: @created_at,
      completed_at: @completed_at,
      run_time: run_time,
      row_count: @config.row_count,
      subdomain: @config.subdomain,
      domain: @config.domain,
      data: @data.summary(data: data)
    }
  end

  def self.calculate_run_time(start_time)
    end_time = Time.now
    start_time = Time.parse(start_time)
    duration_in_seconds = end_time - start_time
  
    seconds = duration_in_seconds % 60
    minutes = (duration_in_seconds / 60) % 60
    hours = (duration_in_seconds / 3600)
  
    "#{hours.to_i}h #{minutes.to_i}m #{seconds.round(2)}s"
  end

  private

  def generate_id
    timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
    unique_id = SecureRandom.hex(4)
    "#{timestamp}-#{@config.subdomain}-#{unique_id}"
  end

  def run_duration(start_time, end_time)
    duration_in_seconds = end_time - start_time
  
    seconds = duration_in_seconds % 60
    minutes = (duration_in_seconds / 60) % 60
    hours = (duration_in_seconds / 3600)
  
    "#{hours.to_i}h #{minutes.to_i}m #{seconds.round(2)}s"
  end

  def start_keystore_update_thread
    Thread.new do
      until @stop_update_thread
        @keystore.set(@id, summary)
        sleep 1
      end
    end
  end
end
