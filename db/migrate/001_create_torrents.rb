class CreateTorrents < ActiveRecord::Migration
  def change
    create_table :torrents do |t|
      t.string :announce
      t.string :announce_list, array: true
      t.datetime :creation_date
      t.string :comment
      t.string :created_by
      t.string :encoding

      t.integer :piece_length
      t.integer :private

      t.string :name

      t.integer :length
      t.string :md5sum

      t.jsonb :files
    end
  end
end