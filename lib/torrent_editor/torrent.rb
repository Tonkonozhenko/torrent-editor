# =Class for presenting whole torrent file
module TorrentEditor
  class Torrent < ActiveRecord::Base
    # Accordance db fields to torrent fields
    ATTRIBUTES = {
      announce: 'announce',
      announce_list: 'announce-list',
      comment: 'comment',
      creation_date: 'creation date',
      created_by: 'created by',
      encoding: 'encoding'
    }

    INFO_ATTRIBUTES = {
      piece_length: 'piece length',
      pieces: 'pieces',
      private: 'private',
      name: 'name'
    }

    # DB associations
    has_many :files, class_name: TorrentFile, autosave: true
    accepts_nested_attributes_for :files, allow_destroy: true

    # Default initialize from hash or from file
    def initialize(attributes)
      if attributes.is_a?(Tempfile) || attributes.is_a?(File)
        super({})
        normalize_from_file(attributes)
      else
        super(attributes)
      end
      self
    end

    # Parsing torrent file
    def normalize_from_file(file)
      file = open(file).read
      content = BEncode::Parser.new(file).parse!

      # Simple fields
      ATTRIBUTES.except(:creation_date).each { |k, v| send("#{k}=", content[v]) }
      INFO_ATTRIBUTES.except(:pieces).each { |k, v| send("#{k}=", content['info'][v]) }
      # Some specific fields
      self.pieces = Base64.encode64(content['info']['pieces'])
      self.creation_date = Time.at(content['creation date'])

      # Parsing either in single-file or multi-file mode
      torrent_with_single_file = content['info']['files'].blank?
      if torrent_with_single_file
        files.build(content['info'].slice('length', 'md5sum'))
      else
        files.build content['info']['files']
      end
    end

    # Predicate whether torrent is a directory or a file
    def is_directory?
      files.count > 1
    end

    def is_file?
      !is_directory?
    end

    # Generating hash for torrent file and bencoding it
    def to_torrent
      content = {
        'announce' => announce,
        'announce-list' => announce_list,
        'creation date' => creation_date.to_i,
        'comment' => comment,
        'created by' => created_by,
        'encoding' => encoding,
        'info' => {
          'piece length' => piece_length,
          'pieces' => Base64.decode64(pieces).force_encoding('UTF-8'),
          'private' => private,
          'name' => name
        }
      }
      content['info'].merge!(
        if is_file?
          file = files.first
          {
            'length' => file.length,
            'md5sum' => file.md5sum,
          }
        else
          {
            'files' => files.map do |f|
              TorrentFile::ATTRIBUTES
                .select { |e| f.send(e).present? }
                .inject({}) { |hsh, e| hsh[e] = f.send(e); hsh }
            end
          }
        end
      )

      content.bencode
    end
  end
end
