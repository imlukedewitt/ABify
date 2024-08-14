# frozen_string_literal: true

# reduce the number of writes to firestore by batching them
class BatchUpdater
  BATCH_SIZE = 200

  def initialize(firestore_client)
    @firestore_client = firestore_client
    @updates = []
    @threads = []
    @mutex = Mutex.new
    @shutdown = false
  end

  def add_update(importer_id, row_id, data)
    should_flush = false

    @mutex.synchronize do
      @updates << { importer_id: importer_id, row_id: row_id, data: data }
      should_flush = @updates.count >= BATCH_SIZE
    end

    flush_updates if should_flush
  end

  def flush_updates
    updates_to_flush = nil
    @mutex.synchronize do
      return if @updates.empty?

      updates_to_flush = @updates.dup
      @updates.clear
    end

    return if updates_to_flush.nil?

    thread = Thread.new do
      @firestore_client.firestore.batch do |batch|
        updates_to_flush.each do |update|
          doc_ref = @firestore_client.firestore.doc("importers/#{update[:importer_id]}/rows/#{update[:row_id]}")
          batch.set(doc_ref, update[:data], merge: true)
        end
      end
      puts "\nflushed #{updates_to_flush.count} updates to firestore\n"
    end

    @mutex.synchronize do
      @threads << thread
    end
  end

  def shutdown
    need_to_flush = false
    @mutex.synchronize do
      need_to_flush = !@updates.empty?
    end
    flush_updates if need_to_flush
    @mutex.synchronize do
      @threads.each(&:join)
      @shutdown = true
    end
  end
end
