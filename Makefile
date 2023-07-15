test:
	forge test

build:
	forge build

deploy:
	# ENV should include ETH_RPC_URL, ETH_PRIVATE_KEY, KETHER_*
	forge script script/Deploy.s.sol:Deploy --rpc-url "$(ETH_RPC_URL)" --broadcast --verify -vvvv

fork:
	anvil --fork-url "$(ETH_RPC_URL)"

.PHONY: test build

