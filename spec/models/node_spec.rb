require 'rails_helper'

describe Node do
  describe '#parent' do
    it 'can be nil' do
      node = create(:node, parent: nil)
      expect(node).to be_valid
    end

    it 'can be another node' do
      parent_node = create(:node, parent: nil)
      child_node = create(:node, parent: parent_node)

      expect(child_node.parent).to eq parent_node
    end

    it 'cannot be itself' do
      node = create(:node, parent: nil)
      node.parent = node

      expect(node).not_to be_valid
    end
  end

  describe '#ancestor_ids' do
    let!(:root_node) { create(:node, parent: nil) }
    let!(:depth_1_node) { create(:node, parent: root_node) }
    # This is here to ensure we aren't including indirect ancestors
    let!(:other_depth_1_node) { create(:node, parent: root_node) }
    let!(:depth_2_node) { create(:node, parent: depth_1_node) }

    it 'returns an array of its own id for nodes with no parent' do
      expect(root_node.ancestor_ids).to eq [root_node.id]
    end

    it 'returns an array of ancestor ids with root node at the top' do
      expect(depth_2_node.ancestor_ids).to eq [root_node.id, depth_1_node.id, depth_2_node.id]
    end
  end

  describe '.all_descendant_ids' do
    let!(:root_node) { create(:node, parent: nil) }
    let!(:depth_1_node) { create(:node, parent: root_node) }
    # This is here to ensure we aren't including indirect ancestors
    let!(:other_depth_1_node) { create(:node, parent: root_node) }
    let!(:depth_2_node) { create(:node, parent: depth_1_node) }

    it 'returns an array of its own id for nodes with no descendants' do
      expect(Node.all_descendant_ids([depth_2_node.id])).to eq [depth_2_node.id]
    end

    it "returns an array of all descendants' ids for a given node" do
      expect(Node.all_descendant_ids([root_node.id])).to eq(
        [root_node.id, depth_1_node.id, other_depth_1_node.id, depth_2_node.id]
      )
    end

    it 'returns all descendants of multiple unrelated nodes' do
      result = Node.all_descendant_ids(
        [depth_1_node.id, other_depth_1_node.id]
      )

      expect(result).to eq [depth_1_node.id, other_depth_1_node.id, depth_2_node.id]
    end

    it 'does not return duplicates when given nodes that are ancestors' do
      result = Node.all_descendant_ids([root_node.id, depth_1_node.id])

      expect(result).to eq(
        [root_node.id, depth_1_node.id, other_depth_1_node.id, depth_2_node.id]
      )
    end
  end

  describe '.common_ancestor' do
    # Note these nodes are taken directly from the problem statement, using the given ids
    let!(:node_130) { create(:node, id: 130, parent: nil) }
    let!(:node_125) { create(:node, id: 125, parent: node_130) }
    let!(:node_2820230) { create(:node, id: 2_820_230, parent: node_125) }
    let!(:node_4430546) { create(:node, id: 4_430_546, parent: node_125) }
    let!(:node_5497637) { create(:node, id: 5_497_637, parent: node_4430546) }

    let!(:node_9) { create(:node, id: 9, parent: nil) }

    context 'when the nodes share an ancestor' do
      it 'works when neither is a direct ancestor of the other' do
        expect(described_class.common_ancestor(5_497_637, 2_820_230)).to eq(
          { root_id: 130, lowest_common_ancestor: 125, depth: 2 }
        )
      end

      it 'works when one node is the root ancestor of the other' do
        expect(described_class.common_ancestor(5_497_637, 130)).to eq(
          { root_id: 130, lowest_common_ancestor: 130, depth: 1 }
        )
      end

      it 'works when the lowest common ancestor is not the root ancestor' do
        expect(described_class.common_ancestor(5_497_637, 4_430_546)).to eq(
          { root_id: 130, lowest_common_ancestor: 4_430_546, depth: 3 }
        )
      end

      it 'works when the two nodes are the same node' do
        expect(described_class.common_ancestor(4_430_546, 4_430_546)).to eq(
          { root_id: 130, lowest_common_ancestor: 4_430_546, depth: 3 }
        )
      end

      it 'works when the two nodes are the same, and also root nodes' do
        expect(described_class.common_ancestor(130, 130)).to eq(
          { root_id: 130, lowest_common_ancestor: 130, depth: 1 }
        )
      end
    end

    context 'when the nodes do not share an ancestor' do
      it 'returns a null result' do
        expect(described_class.common_ancestor(9, 4_430_546)).to eq(
          { root_id: nil, lowest_common_ancestor: nil, depth: nil }
        )
      end
    end
  end
end
