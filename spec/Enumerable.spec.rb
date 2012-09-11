require_relative '../src/Enumerize'


class Collection; include Enumerize end

describe "Enumerize" do

  before :each do
    @collection = Collection.new
    @collection.stub( :each ).and_yield( 1 ).and_yield( 2 )
  end

  it "should work" do
    expect( true ).to eq( true )
  end

  describe "#all" do

    context "when a block is given" do
      before :each do
        @result = @collection.all? { |thing| thing > 0 }
      end

      it "returns true if block returns not nil/false for all" do
        expect( @result ).to eq( true )
      end

      it "returns false if block return false" do
        result = @collection.all? { |thing| thing == 0 }
        expect( result ).to eq( false )
      end
    end

    context "when no block is given" do
      before :each do
        @result = @collection.all?
      end

      it "returns true if none of the objects are nil or false" do
        expect( @result ).to equal( true )
      end

      it "returns false if one of the objects is nil" do
        @collection.stub( :each ).and_yield( 1 ).and_yield( nil )
        result = @collection.all?
        expect( result ).to eq( false )
      end

      it "returns false if one of the objects is false" do
        @collection.stub( :each ).and_yield( 1 ).and_yield( false )
        result = @collection.all?
        expect( result ).to eq( false )
      end
    end
  end

  describe "#any" do

    context "when a block is given" do

      it "returns false if block returns nil" do
        result = @collection.any? { nil }
        expect( result ).to eq( false )
      end

      it "returns false if block returns false" do
        result = @collection.any? { false }
        expect( result ).to eq( false )
      end

      it "returns true if block returns something other than false/nil" do
        result = @collection.any? { "tacos" }
        expect( result ).to eq( true )
      end
    end

    context "when a block is not given" do

      it "returns true if at least one of the members is not false/nil" do
        @collection.stub( :each ).and_yield( "yo" ).and_yield( false )
        result = @collection.any?
        expect( result ).to eq( true )
      end

      it "returns false if all members either false/nil" do
        @collection.stub( :each ).and_yield( nil ).and_yield( false )
        result = @collection.any?
        expect( result ).to eq( false )
      end

    end

  end

  describe "#chunk" do
    before :each do
      @collection.stub( :each ).and_yield( 1 )
        .and_yield( 1 ).and_yield( 2 ).and_yield( 1 ).and_yield( 3 )
    end

    context "when not passed state in the block" do
      before :each do
        @result = @collection.chunk { |piece| piece }
      end

      it "returns an array grouped by block return value" do
        expect( @result[ 0 ] ).to eq( [ 1, [1,1] ] )
        expect( @result[ 1 ] ).to eq( [ 2, [2] ] )
        expect( @result[ 2 ] ).to eq( [ 1, [1] ] )
        expect( @result[ 3 ] ).to eq( [ 3, [3] ] )
      end
    end

    context "when passed state in the block" do

      before :each do
        @state_handler = {}
        @state_handler.stub( :handle )
        @result = @collection.chunk( 0 ) { |piece,state|
          piece}
      end

      it "passes state as second param to the block" do
        @state_handler.should_receive( :handle )
        @collection.chunk( 0 ) { |piece,state| @state_handler.handle( state ) }
      end

      it "returns an array grouped by block return value" do
        expect( @result[ 0 ] ).to eq( [ 1, [1,1] ] )
        expect( @result[ 1 ] ).to eq( [ 2, [2] ] )
        expect( @result[ 2 ] ).to eq( [ 1, [1] ] )
        expect( @result[ 3 ] ).to eq( [ 3, [3] ] )
      end

    end

    context "when block returns nil" do

      before :each do
        @result = @collection.chunk { |piece|
          if piece == 2
            next nil
          end
          piece
        }
      end

      it "drops elements if block returns nil" do
        expect( @result[ 0 ] ).to eq( [ 1, [1,1,1] ] )
        expect( @result[ 1 ] ).to eq( [ 3, [3] ] )
      end

    end

    context "when block returns :_" do

      before :each do
        @result = @collection.chunk { |piece|
          if piece == 2
            next :_
          end
          piece
        }
      end

      it "drops elements if block returns nil" do
        expect( @result[ 0 ] ).to eq( [ 1, [1,1,1] ] )
        expect( @result[ 1 ] ).to eq( [ 3, [3] ] )
      end
    end

  end

  describe "#map #collect" do

    context "when passed a block" do

      before :each do
        @result = @collection.map { | thing | thing + 1 }
      end

      it "returns an array with the transformation passed on each member" do
        expect( @result ).to eq( [2,3] )
      end
    end

    context "when not passed a block" do

      before :each do
        @result = @collection.map
      end

      it "returns an enmerator" do
        expect( @result.next ).to eq( 1 )
        expect( @result.next ).to eq( 2 )
        expect{ @result.next }.to raise_error( StopIteration )
      end

    end

  end

  describe "#flat_map #flat_collect" do

    before :each do
      @collection.stub( :each ).and_yield([1,2]).and_yield([3,4])
    end

    context "when passed a block" do

      before :each do
        @result = @collection.flat_map { |thing| thing + 1 }
      end

      it "returns a flattened array w/results of block applied to each" do
        expect( @result ).to eq( [2,3,4,5] )
      end

    end

    context "when not passed a block" do

      before :each do
        @result = @collection.flat_map
      end

      it "returns an enumerator of a flattened version of each" do
        expect( @result.next ).to eq(1)
        expect( @result.next ).to eq(2)
        expect( @result.next ).to eq(3)
        expect( @result.next ).to eq(4)
        expect{ @result.next }.to raise_error( StopIteration )
      end

    end

  end
end
