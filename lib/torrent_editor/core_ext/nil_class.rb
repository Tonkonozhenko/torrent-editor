# Monkey-patch for bencoding nil
class NilClass
  def bencode
    ''
  end
end
