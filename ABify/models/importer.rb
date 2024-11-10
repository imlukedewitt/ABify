# frozen_string_literal: true

require 'typhoeus'
require 'securerandom'
require_relative 'hydra_logger'
require_relative '../workflows/workflow'
require_relative '../helpers/csv_writer'
require_relative '../helpers/utils'
require_relative '../helpers/string_utils'

# An Importer runs a workflow on a set of data
# The config object is passed to each step to help build requests
class Importer
  include Utils
  include StringUtils

  attr_reader :status, :id, :data

  def initialize(config, workflow, data)
    @config = config
    @id = generate_id
    @config.id = @id
    config.row_count = data.rows.count
    config.logger = HydraLogger.new(@id)
    @workflow = workflow
    @data = data
    @hydra = Typhoeus::Hydra.new(max_concurrency: 25)
    @status = 'not started'
    @created_at = Time.now
    @keystore = config.keystore

    @keystore.set(@id, summary)
    setup_steps
  end

  def start
    @status = 'running'
    @keystore.set(@id, summary)
    puts 'starting import'
    first_step, *next_steps = @workflow.steps

    @data.rows.each do |row|
      first_step&.enqueue(row, @hydra, next_steps, @config)
    end

    @hydra.run
    @status = 'complete'
    @completed_at = Time.now
    @keystore.set(@id, summary)
    CSVWriter.new(@id).write_import_results(summary)
    puts "\n\ngreat job"
  end

  def summary(data: true)
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
      data: @data.summary(data: data)
    }
  end
end
