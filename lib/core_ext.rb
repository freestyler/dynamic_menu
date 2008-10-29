class Hash
  def include_hash?(other_hash)
    other_hash.each do |key, value|
      return false if self[key] != other_hash[key]
    end
    true
  end
end
