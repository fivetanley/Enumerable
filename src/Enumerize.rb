module Enumerize

  def all?( &block )
    block = Proc.new { |thing| thing } unless block_given?
    everything_matches = true
    each do | thing |
      block_result = block.call thing
      everything_matches = block_result != nil && block_result != false
      break unless everything_matches
    end
    everything_matches
  end

  def any?( &block )
    block = Proc.new{ |thing| thing } unless block_given?
    something_matches = false
    each do | thing |
      block_result = block.call( thing )
      something_matches = (block_result != nil && block_result != false)
      break unless !something_matches
    end
    something_matches
  end

  def chunk( *state, &block )
    chunks =  []
    state = nil unless state
    last_block_value = nil
    current_index = 0
    each do | thing |
      case block.arity
      when 1
        block_value = block.call( thing )
      when 2
        block_value = block.call( thing, state )
      end
      if block_value == nil || block_value == :_ then next end
      if chunks.empty?
        last_block_value = block_value
        chunks.push( [ block_value, [ thing ] ] )
        next
      end
      if block_value != last_block_value
        current_index += 1
        chunks.push( [ block_value, [thing] ] )
        last_block_value = block_value
        next
      end
        chunks[ current_index ][ 1 ].push( thing )
    end
    chunks
  end

  def map( &block )
    map = []
    if !block_given?
      enum = Enumerator.new do |yielder|
        each do | thing |
          yielder << thing
        end
      end
      return enum
    end
    each do | thing |
      map << block.call( thing )
    end
    map
  end

  def collect (&block)
    map( &block )
  end

  def flat_map( &block )
    def recursive_each( memo, list, block )
      if list.respond_to?( 'each' )
        list.each do | item |
          recursive_each(memo, item, block)
        end
      else
        if memo != nil
          memo << block.call( list )
        #handle yield
        else
          block << list
        end
      end
    end
    if !block_given?
      Enumerator.new do |yielder|
        each do | thing |
          recursive_each( nil, thing, yielder )
        end
      end
    else
    flat_map = []
      each do | thing |
        recursive_each( flat_map, thing, block )
      end
      flat_map
    end
  end

  def flat_collect( &block )
    flat_map( block )
  end

  def count( *item, &block )
    counter = 0
    if item.size == 1
      comparator = item[ 0 ]
    end
    each do | thing |
      if block_given?
        counter += 1 unless block.call( thing ) != true
      else
        item = comparator || thing
        counter += 1 unless item != thing
      end
    end
    counter
  end

  def cycle( *cycles, &block )
    cycles = cycles[ 0 ]
    if !block_given?
      return Enumerator.new do | yielder |
        cycles.times do | num |
          each do | thing |
            yielder << thing
          end
        end
      end
    end
    cycles.times do | num |
      each do | thing |
        block.call( thing )
      end
    end
  end

  def detect( *ifnone, &block )
    if !block_given?
      return Enumerator.new do |yielder|
        each do | thing |
          yielder << thing
        end
      end
    end
    ifnone = ifnone[ 0 ] unless ifnone.size == 0
    each do | thing |
      return thing unless block.call( thing ) != true
    end
    return ifnone.call

  end

end

