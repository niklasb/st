

    struct TokenBatch {
        uint256 amount;
        uint64 withdrawalDeadline;
    }

    struct Holder {
        address addr;
        uint256 reclaimableAmount; // Amount (in EUR) the holder is owed
        TokenBatch[] batches;
    }

    mapping(address => Holder);

    function withdrawFromContract(uint256 batchNumber) {
        // Find data structures in memory
        Holder storage holder = holders[msg.sender];
        TokenBatch storage batch = holder.batches[batchNumber];
        // Check the withdrawal deadline against current time
        require(now <= batch.withdrawalDeadline);
        // Return EUR
        holder.reclaimableAmount += batch.amount;
        // Burn tokens
        batch.amount = 0;
    }

