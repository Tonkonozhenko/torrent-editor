module TorrentEditor
  class TorrentFile
    attr_accessor :length, :md5sum, :path

    def initialize(data)
      update(data)
    end

    def update(data)
      @length = data['length']
      @md5sum = data['md5sum']
      @path = data['path']
    end

    def bencode
      %i[length md5sum path].select { |e| send(e).present? }.inject({}) { |hsh, e| hsh[e] = send(e); hsh }.bencode
    end
  end
end