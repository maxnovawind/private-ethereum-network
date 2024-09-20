# Setup/Deploy the blockchain


The private ethereum network will be deployed on the k8s cluster. So it is necessary to adapt the helm-chart of the blockchain folder helm-charts/ethereum:

```
helm-charts/ethereum
├── besu-genesis
│   ├── Chart.yaml
│   ├── secret.yaml
│   ├── templates
│   ├── values.genesis.local.yaml
│   └── values.yaml
├── besu-node
│   ├── Chart.yaml
│   ├── secret.yaml
│   ├── templates
│   ├── values.bootnode.local.yaml
│   ├── values.rpc.local.yaml
│   ├── values.validator.local.yaml
│   └── values.yaml
```

The `besu-genesis` chart is used to generate the genesis file and the key pairs for each validator node. In our setup, we have 4 validators to comply with the PBFT consensus algorithm, which allows for 1 faulty node: (N = 3F + 1 => 4 = 3*1 + 1).


The `besu-node` chart is used to deploy the besu nodes :
- 1 bootnode use values.bootnode.local.yaml
- 4 validators use values.validator.local.yaml
- 1 rpc node use values.rpc.local.yaml

## Step 1: Generate the genesis file with the besu-genesis chart

The genesis file is used to bootstrap the network. It contains the initial configuration of the network, such as the initial validators and the initial parameters of the network.


The following parameters are used to configure the genesis file :
```
rawGenesisConfig:
  genesis:
    config:
      chainId: 1337
      algorithm:
        consensus: qbft # choose from: ibft2 | qbft | clique
        blockperiodseconds: 10
        epochlength: 30000
        requesttimeoutseconds: 20
    # we recommend setting the gas limit to 0x1fffffffffffff for private chains
    gasLimit: '0x1fffffffffffff'
    difficulty: '0x1'
    coinbase: '0x0000000000000000000000000000000000000000'
    includeQuickStartAccounts: false
  blockchain:
    nodes:
      generate: true
      count: 4
    accountPassword: 'password'
```

In our case, configure the right `blockperiodseconds` and `requesttimeoutseconds` to fit with the validator nodes (tune these validator if you have some latency issues). If `blockperiodseconds` is too low, validators are overwhelmed by rapid block proposals, leading to high CPU usage, frequent round changes, and potential validator failures, which can halt the network. If it's too high, like 60 seconds, transaction finality is slow, validators are underutilized, network throughput drops, and recovery from failed rounds takes longer, causing delays and inefficiencies. Optimal block time should balance these factors to ensure both performance and stability.

In the other hand, It recommend to set the gasLimit to `0x1fffffffffffff` for private chains for free gas network.

**Important note: Deploy with genesis argocd application before running the next steps.**

## Step 2: Deploy the bootnodes (recommended)

Bootnodes and static nodes are parallel methods for finding peers. Depending on your use case, you can use only bootnodes, only static nodes, or both bootnodes and static nodes.

**Important note: Deploy with bootnode argocd application before running the next steps.**

## Step 3: Deploy the initial pool of validators nodes

In this step, we will deploy the initial pool of validators nodes. The validators nodes are used to validate the transactions and to reach consensus.

**Important note: Deploy with validator argocd application before running the next steps.**

## Step 4: Deploy the rpc node (optional, but recommended)

The rpc node is used to provide an interface to the blockchain. It is used by the users to interact with the blockchain. This node supports heavy load write and read operations. It's recommended to interconnect the dapps/indexer/explorer to this node RPC.

**Important note: Deploy with rpc argocd application before running the next steps.**


[[Back To Architecture]](./Architecture-blockchain.md) [[Go To README]](../README.md)