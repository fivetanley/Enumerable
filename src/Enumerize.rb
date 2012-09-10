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
end
