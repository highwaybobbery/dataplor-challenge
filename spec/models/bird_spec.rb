require 'rails_helper'

RSpec.describe Bird, type: :model do
  describe '.for_all_descendants_of' do
    context 'with non-existant node_ids' do
      it 'returns an empty array' do
        expect(described_class.for_all_descendants_of([123, 456])).to eq []
      end
    end

    context 'when existing nodes have no birds in there descendants' do
      let!(:node_a) { create(:node, id: 123, parent_id: nil) }
      let!(:node_b) { create(:node, id: 456, parent_id: 123) }

      it 'returns an empty array' do
        expect(described_class.for_all_descendants_of([123, 456])).to eq []
      end
    end

    context 'when existing nodes have birds in their descendants' do
      let!(:node_a) { create(:node, id: 123, parent_id: nil) }
      let!(:node_b) { create(:node, id: 456, parent_id: 123) }
      let!(:node_c) { create(:node, id: 789, parent_id: nil) }
      let!(:node_d) { create(:node, id: 555, parent_id: nil) }

      let!(:bird_a) { create(:bird, id: 1, name: 'joe', node_id: 456) }
      let!(:bird_b) { create(:bird, id: 2, name: 'jane', node_id: 456) }
      let!(:bird_c) { create(:bird, id: 3, name: 'jimmy', node_id: 789) }
      let!(:bird_d) { create(:bird, id: 4, name: 'noop', node_id: 555) }

      it 'returns the birds for all descendants' do
        expect(described_class.for_all_descendants_of([123, 789])).to eq(
          [
            { id: 1, node_id: 456, name: 'joe' },
            { id: 2, node_id: 456, name: 'jane' },
            { id: 3, node_id: 789, name: 'jimmy' }
          ]
        )
      end

      context 'when one passed node is an ancestor to another passed node' do
        it 'does not return the same bird twice' do
          expect(described_class.for_all_descendants_of([123, 456])).to eq(
            [
              { id: 1, node_id: 456, name: 'joe' },
              { id: 2, node_id: 456, name: 'jane' }
            ]
          )
        end
      end
    end
  end
end
