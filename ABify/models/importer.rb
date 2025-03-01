# frozen_string_literal: true

require 'typhoeus'
require_relative 'hydra_logger'
require_relative '../workflows/workflow'
require_relative '../helpers/csv_writer'
require_relative '../helpers/utils'
require_relative '../helpers/string_utils'
require_relative 'buffer_step'

# An Importer runs a workflow on a set of data
# The config object is passed to each step to help build requests
class Importer
  include Utils
  include StringUtils

  attr_reader :status, :id, :data

  def initialize(config, workflow, data)
    @config = config
    @config.row_count = data.rows.count
    @workflow = workflow
    @data = data
    setup_id_and_logger
    setup_hydra
    setup_status_and_time
    setup_keystore
    setup_steps
  end

  def start
    @status = 'running'
    @keystore.set(@id, summary)

    queue_rows

    @hydra.run
    @status = 'complete'
    @completed_at = Time.now
    @keystore.set(@id, summary)
    CSVWriter.new(@id).write_import_results(summary)
    puts "\n\ngreat job"
  end

  def summary(data: false, original_data: true)
    end_time = @completed_at || Time.now
    run_time = duration(@created_at, end_time)
    {
      id: @id,
      status: @status,
      created_at: @created_at,
      completed_at: @completed_at,
      run_time: run_time,
      row_count: @config.row_count,
      completed_rows: @data.completed_row_count,
      failed_rows: @data.failed_row_count,
      subdomain: @config.subdomain,
      domain: @config.domain,
      rows: @data.summary(data: data, original_data: original_data)
    }
  end

  private

  def setup_id_and_logger
    @id = generate_id
    @config.id = @id
    @config.logger = HydraLogger.new(@id)
  end

  def setup_hydra
    @hydra = Typhoeus::Hydra.new(max_concurrency: 25)
  end

  def setup_status_and_time
    @status = 'not started'
    @created_at = Time.now
  end

  def setup_keystore
    @keystore = @config.keystore
    @keystore.set(@id, summary)
  end

  def setup_steps
    @workflow.steps.each do |step|
      step.config = @config
    end
  end

  def queue_rows
    @data.rows.each do |row|
      queue_buffer_step(row)
    end
  end

  def queue_buffer_step(row)
    buffer_step = BufferStep.new(@config)
    buffer_step.enqueue(row, @hydra, @workflow.steps)
  end
end
