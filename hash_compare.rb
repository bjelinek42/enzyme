#You have 2 hashes. You are looking for the difference between the 2. What was added or removed or if the hash is the same.

# Hash only have string keys
# Hash only have string, boolean, number, array or hash as value
# Compare should have an option for deep () or shallow compare
# Compare should list the difference for keys and values

#is there more than one difference? as it is worded "difference" I will assume only one difference for the exercise
#shallow compare is first level, deep is many levels into hashes/arrays
#differentiate between added and removed

#search through keys for difference, return differences
#search through each value for differences
  #conditionals for string, boolean, integer
  #loop through arrays and hashes as before for deeper compare
  #return difference

class HashCompare

  def initialize(first_hash, second_hash)
    @first_hash = first_hash
    @second_hash = second_hash
    @change = {}
  end

  def shallow_compare
    if same? == true
      return @change = {changes: 'none'}
    end
    @first_hash.each do |k, v| #find removed k:v
      if @second_hash[k] == nil
        return @change = {removed: {k => v}}
      else
        if @second_hash[k] != v #if no keys removed, find changed values
          return @change = {changed_value_from: {k => v}, changed_value_to: {k => @second_hash[k]}}
        end
      end
    end
    @second_hash.each do |k, v| #find added k:v
      if @first_hash[k] == nil
        return @change = {added: {k => v}}
      end
    end
  end

  def deep_compare #i believe the best approach is recursion to get deeper and deeper into nested hashes/arrays as you do not know how deep they may go
    #I will explain what I think a good approach to this due to time and I am not familiar with recursion this complex
    #first do same comparisons for shallow_compare to catch easy changes
    #if a change is found in the array/hash, loop through, comparing to same value in second_hash
      #begin comparing again if difference is found in another array/hash
      #when difference is found that is not array/hash, return the added/removed/changed value
      #otherwise continue to go deeper until specific difference is found
  end

  def same?
    if @first_hash == @second_hash
      return true
    else
      return false
    end
  end
end

require 'test/unit'

class HashCompareTest < Test::Unit::TestCase
  description 'shallow compare returns first level removals, additions, and changes'
  description 'returns key value pair if removed from first_hash to second_hash'
  def test1
    @first_hash = {"key1" => "string", "key2" => true, "key3" => 4, "key4" => [1, 2, 3], "key5" => {"key6" => "string", "key8" => true, "key8" => 4}}
    @second_hash = {"key2" => true, "key3" => 4, "key4" => [1, 2, 3], "key5" => {"key6" => "string", "key8" => true, "key8" => 4}}
    shallow_difference
    assert_equal @change, {removed: {"key1" => "string"}}
  end

  description 'returns key value pair if added from first_hash to second_hash'
  def test2
    @first_hash = {"key1" => "string", "key2" => true, "key3" => 4, "key4" => [1, 2, 3], "key5" => {"key6" => "string", "key8" => true, "key8" => 4}}
    @second_hash = {"key1" => "string", "key2" => true, "key3" => 4, "key4" => [1, 2, 3], "key5" => {"key6" => "string", "key8" => true, "key8" => 4}, "key10" => "I was added"}
    shallow_difference
    assert_equal @change, {added: {"key10" => "I was added"}}
  end

  description 'returns the changed key value pair if value is a string and was changed from first_hash to second_hash'
  def test3
    @first_hash = {"key1" => "string", "key2" => true, "key3" => 4, "key4" => [1, 2, 3], "key5" => {"key6" => "string", "key7" => true, "key8" => 4}}
    @second_hash = {"key1" => "new_string", "key2" => true, "key3" => 4, "key4" => [1, 2, 3], "key5" => {"key6" => "string", "key7" => true, "key9" => 4}}
    shallow_difference
    assert_equal @change, {changed_value_from: {"key1" => "string"}, changed_value_to: {"key1" => "new_string"}}
  end

  description 'returns the changed key value pair if value is a boolean and was changed from first_hash to second_hash'
  def test4
    @first_hash = {"key1" => "string", "key2" => true, "key3" => 4, "key4" => [1, 2, 3], "key5" => {"key6" => "string", "key7" => true, "key8" => 4}}
    @second_hash = {"key1" => "string", "key2" => false, "key3" => 4, "key4" => [1, 2, 3], "key5" => {"key6" => "string", "key7" => true, "key8" => 4}}
    shallow_difference
    assert_equal @change, {changed_value_from: {"key2" => true}, changed_value_to: {"key2" => false}}
  end

  description 'returns the changed key value pair if value is a integer and was changed from first_hash to second_hash'
  def test5
    @first_hash = {"key1" => "string", "key2" => true, "key3" => 4, "key4" => [1, 2, 3], "key5" => {"key6" => "string", "key7" => true, "key8" => 4}}
    @second_hash = {"key1" => "string", "key2" => true, "key3" => 8, "key4" => [1, 2, 3], "key5" => {"key6" => "string", "key7" => true, "key8" => 4}}
    shallow_difference
    assert_equal @change, {changed_value_from: {"key3" => 4}, changed_value_to: {"key3" => 8}}
  end

  description 'returns the changed key value pair if value is an array and was changed from first_hash to second_hash'
  def test6
    @first_hash = {"key1" => "string", "key2" => true, "key3" => 4, "key4" => [1, 2, 3], "key5" => {"key6" => "string", "key7" => true, "key8" => 4}}
    @second_hash = {"key1" => "string", "key2" => true, "key3" => 4, "key4" => [1, 3], "key5" => {"key6" => "string", "key7" => true, "key8" => 4}}
    shallow_difference
    assert_equal @change, {changed_value_from: {"key4" => [1, 2, 3]}, changed_value_to: {"key4" => [1, 3]}}
  end

  description 'returns the changed key value pair if value is a hash and was changed from first_hash to second_hash'
  def test7
    @first_hash = {"key1" => "string", "key2" => true, "key3" => 4, "key4" => [1, 2, 3], "key5" => {"key6" => "string", "key7" => true, "key8" => 4}}
    @second_hash = {"key1" => "string", "key2" => true, "key3" => 4, "key4" => [1, 2, 3], "key5" => {"key6" => "string", "key8" => 4}}
    shallow_difference
    assert_equal @change, {changed_value_from: {"key5" => {"key6" => "string", "key7" => true, "key8" => 4}}, changed_value_to: {"key5" => {"key6" => "string", "key8" => 4}}}
  end

  description "returns 'none' for @change when the hashes are equal"
  def test8
    @first_hash = {"key1" => "string", "key2" => true, "key3" => 4, "key4" => [1, 2, 3], "key5" => {"key6" => "string", "key7" => true, "key8" => 4}}
    @second_hash = {"key1" => "string", "key2" => true, "key3" => 4, "key4" => [1, 2, 3], "key5" => {"key6" => "string", "key7" => true, "key8" => 4}}
    shallow_difference
    assert_equal @change, {changes: 'none'}
  end

  private

    def shallow_difference
      new_compare = HashCompare.new(@first_hash, @second_hash)
      @change = new_compare.shallow_compare
    end
end