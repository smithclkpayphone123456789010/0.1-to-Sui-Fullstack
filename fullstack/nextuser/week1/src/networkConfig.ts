import { getFullnodeUrl,SuiClient } from "@mysten/sui/client";
import { createNetworkConfig, useSuiClient } from "@mysten/dapp-kit";
/**
来自合约publish 的日志  contracts/pub-test.out
│  ┌──                                                                                                    │
│  │ ObjectID: 0x305d297d2d05efc906efe9bdd8027592661e71107c405dea83d9658754d938ad                         │
│  │ Sender: 0x5e23b1067c479185a2d6f3e358e4c82086032a171916f85dc9783226d7d504de                           │
│  │ Owner: Shared( 302154258 )                                                                           │
│  │ ObjectType: 0xbbb82090bf6c88a8a43dd07fd0826200875624926ad3e0a27b038c6262b03dcb::week_one_alt::State  │
│  │ Version: 302154258                                                                                   │
│  │ Digest: 41cvi526yqWZqhwEMm7iyVZm2f1XhCRLXQK4AgqpVgfM                                                 │
│  └── 
 */
const { networkConfig, useNetworkVariable, useNetworkVariables } =
  createNetworkConfig({
    devnet: {
      url: getFullnodeUrl("devnet"),
      state:"todo",
      pkg:"todo"
    },
    testnet: {
      url: getFullnodeUrl("testnet"),
      state:'0x305d297d2d05efc906efe9bdd8027592661e71107c405dea83d9658754d938ad',
      pkg:'0xbbb82090bf6c88a8a43dd07fd0826200875624926ad3e0a27b038c6262b03dcb',
    },
    mainnet: {
      url: getFullnodeUrl("mainnet"),
      state:"todo",
      pkg:"todo"
    },
  });

export const config = networkConfig.testnet
///export const suiClient = new SuiClient({ url: config.url });
export { useNetworkVariable, useNetworkVariables, networkConfig };
