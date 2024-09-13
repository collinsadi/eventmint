import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const EventMintPlatformModule = buildModule("EventMintPlatformModule", (m) => {
  const EventMintPlatform = m.contract("EventMintPlatform");

  return { EventMintPlatform };
});

export default EventMintPlatformModule;
