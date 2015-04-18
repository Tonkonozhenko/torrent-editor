class CreateTorrentFiles < ActiveRecord::Migration
  def change
    create_table :torrent_files do |t|
      t.references :torrent, foreign_key: true, index: true

      t.string :path, array: true
      t.integer :length
      t.string :md5sum
    end
  end
end
