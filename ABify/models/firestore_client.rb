# frozen_string_literal: true

require 'google/cloud/firestore'

# placeholder DB, using firestore for now
class FirestoreClient
  attr_reader :firestore

  def initialize
    unless ENV['RUNNING_ON_SERVER']
      ENV['GOOGLE_APPLICATION_CREDENTIALS'] =
        '/Users/luke/implementation/ABify/config/keyfile.json'
    end
    @firestore = Google::Cloud::Firestore.new(project_id: 'smart-template-server')
  end

  def add_importer(data)
    @firestore.col('importers').add(data)
  end

  def update_importer(doc_id, data)
    @firestore.doc("importers/#{doc_id}").set(data, merge: true)
  end

  def add_row(importer_id, data)
    @firestore.doc("importers/#{importer_id}").col('rows').add(data)
  end

  def update_row(importer_id, row_id, data)
    @firestore.doc("importers/#{importer_id}/rows/#{row_id}").set(data, merge: true)
  end
end
