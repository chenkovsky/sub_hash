require "./sub_hash/*"

struct SubHash
  # find a prime number in http://primes.utm.edu/lists/2small/0bit.html
  # 注意避免溢出
  HASH_BITS     = 61
  DefaultModulo = (1_u64 << HASH_BITS) - 1
  DefaultBase   = 257_u64

  @modulo : UInt64
  @base : UInt64
  @power_cache : Array(UInt64)
  @suffix_cache : Array(UInt64)
  @term_size : Int32

  def initialize(@base = DefaultBase, @modulo = DefaultModulo, capacity : Int32 = 256)
    @power_cache = init_power capacity, @base.to_u128
    @suffix_cache = Array(UInt64).new(capacity, 0_u64)
    @term_size = 0
  end

  private def init_power(capacity, base) : Array(UInt64)
    powers = Array(UInt64).new(capacity, 0_u64)
    powers[0] = 1_u64
    (1...capacity).each { |i| powers[i] = ((base * powers[i - 1]) % @modulo).to_u64 }
    powers
  end

  def sub_hash(term) : Void
    @term_size = term.size
    if @power_cache.size < term.size
      capacity = Math.pw2ceil(term.size + 1)
      @power_cache = init_power capacity, @base.to_u128
      @suffix_cache = Array(UInt64).new(capacity, 0_u64)
    end
    @suffix_cache[term.size] = 0_u64
    (0...term.size).reverse_each do |i|
      @suffix_cache[i] = ((@base.to_u128 * @suffix_cache[i + 1] + self.class.convert(term[i])) % @modulo).to_u64
    end
  end

  def [](start, len) : UInt64
    # len shoulde > 0
    return 0_u64 if len <= 0
    len = @term_size - start if len > @term_size - start
    sub = @suffix_cache[start + len].to_u128 * @power_cache[len] % @modulo
    res = (@suffix_cache[start] + @modulo - sub) % @modulo
    res = (res.to_u128) % @modulo
    res.to_u64
  end

  # x[0] + base * x[1] + base^2 * x[2] ....
  def self.hash(term, base : UInt64 = DefaultBase, modulo : UInt64 = DefaultModulo) : UInt64
    return (0...term.size).reverse_each.reduce(0_u128) { |acc, i| (base.to_u128 * acc + convert(term[i])) % modulo }.to_u64
  end

  def self.convert(elem : Char) : UInt64
    elem.ord.to_u64
  end

  def self.convert(elem : Int) : UInt64
    elem.to_u64
  end
end
