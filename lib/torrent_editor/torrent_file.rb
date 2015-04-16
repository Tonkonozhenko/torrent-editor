module TorrentEditor
  class TorrentFile
    attr_accessor :length, :md5sum, :path

    def initialize(data)
      @length = data['length']
      @md5sum = data['md5sum']
      @path = data['path']
      path.map! { |p| p.force_encoding('UTF-8') }
    end

    def bencode
      @content.bencode
    end
  end
end