require 'rails_helper'

describe Node do
  describe 'parent' do
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

    it "it returns an array of it's own id for nodes with no parent" do
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

    it "it returns an array of it's own id for nodes with no descendants" do
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
    # Note these nodes are taken directly from the problem statement,
    # and are named according to the example_ids give.
    # Due to autoincrement on the column the actual ids will be different each run!
    let!(:node_130) { create(:node, parent: nil) }
    let!(:node_125) { create(:node, parent: node_130) }
    let!(:node_2820230) { create(:node, parent: node_125) }
    let!(:node_4430546) { create(:node, parent: node_125) }
    let!(:node_5497637) { create(:node, parent: node_4430546) }

    let!(:node_9) { create(:node, parent: nil) }

    context 'when the nodes share an ancestor' do
      it 'works when neither is a direct ancestor of the other' do
        expect(described_class.common_ancestor(node_5497637.id, node_2820230.id)).to eq(
          { root_id: node_130.id, lowest_common_ancestor: node_125.id, depth: 2 }
        )
      end

      it 'works when one node is the root ancestor of the other' do
        expect(described_class.common_ancestor(node_5497637.id, node_130.id)).to eq(
          { root_id: node_130.id, lowest_common_ancestor: node_130.id, depth: 1 }
        )
      end

      it 'works when the lowest common ancestor is not the root ancestor' do
        expect(described_class.common_ancestor(node_5497637.id, node_4430546.id)).to eq(
          { root_id: node_130.id, lowest_common_ancestor: node_4430546.id, depth: 3 }
        )
      end

      it 'works when the two nodes are the same node' do
        expect(described_class.common_ancestor(node_4430546.id, node_4430546.id)).to eq(
          { root_id: node_130.id, lowest_common_ancestor: node_4430546.id, depth: 3 }
        )
      end

      it 'works when the two nodes are the same root node' do
        expect(described_class.common_ancestor(node_130.id, node_130.id)).to eq(
          { root_id: node_130.id, lowest_common_ancestor: node_130.id, depth: 1 }
        )
      end
    end

    context 'when the nodes do not share an ancestor' do
      it 'returns a null result' do
        expect(described_class.common_ancestor(node_9.id, node_4430546.id)).to eq(
          { root_id: nil, lowest_common_ancestor: nil, depth: nil }
        )
      end
    end
  end
end
