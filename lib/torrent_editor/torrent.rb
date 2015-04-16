require 'open-uri'
require 'bencode'

module TorrentEditor
  class Torrent
    METHODS = {
      announce: 'announce',
      announce_list: 'announce-list',
      comment: 'comment',
      creation_date: 'creation date',
      info: 'info',
      created_by: 'created by',
      encoding: 'encoding'
    }

    INFO_METHODS = {
      piece_length: 'piece length',
      pieces: 'pieces',
      private: 'private',
      name: 'name'
    }

    SINGLE_FILE_METHODS = {
      length: 'length',
      md5sum: 'md5sum'
    }

    MULTIPLE_FILE_METHODS = {
      files: 'files'
    }

    METHODS.each do |local_name, torrent_name|
      define_method local_name do
        @content[torrent_name]
      end

      define_method(:"#{local_name}=") do |value|
        @content[torrent_name] = value
      end
    end

    INFO_METHODS.merge(SINGLE_FILE_METHODS).merge(MULTIPLE_FILE_METHODS).each do |local_name, torrent_name|
      define_method local_name do
        info[torrent_name]
      end

      define_method(:"#{local_name}=") do |value|
        info[torrent_name] = value
      end
    end

    attr_accessor :content, :row

    def initialize(file_or_row)
      file_or_row.is_a?(Tempfile) ? normalize_from_file(file_or_row) : normalize_from_row(file_or_row)
      self
    end

    def normalize_from_row(row)
      @content = { 'info' => {} }
      @row = row
      %i[announce announce_list comment created_by encoding piece_length private name length md5sum files]
        .each { |elem| send("#{elem}=", @row.send(elem)) }
      files.map! { |f| TorrentFile.new(f) } if files
      self.creation_date = @row.creation_date.to_i
    end

    def normalize_from_file(file)
      file = open(file)
      @content = BEncode::Parser.new(file).parse!
      files.map! { |f| TorrentFile.new(f) } if files
      %i[name announce comment created_by encoding pieces].each do |n|
        send("#{n}=", send(n).force_encoding('UTF-8'))
      end
      announce_list.map! { |l| l.map { |e| e.force_encoding('utf-8') } }
    end

    def to_torrent
      @content.bencode
    end

    def bencode
      to_torrent
    end

    def save
      attributes =
        %i[announce announce_list comment created_by encoding piece_length private name length md5sum files]
          .inject({}) do |hsh, elem|
          hsh[elem] = send(elem)
          hsh
        end

      attributes[:creation_date] = Time.at(creation_date)

      if row
        row.update_attributes(attributes)
      else
        @row = DbRecord.create(attributes)
      end
    end

    class << self
      def find(id)
        new(DbRecord.find(id))
      end

      def all
        DbRecord.all
      end
    end
  end
end
