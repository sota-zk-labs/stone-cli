# Stone CLI

A CLI for proving Cairo programs and verifying and serializing Cairo proofs.

## Setup

- Run `cargo install --path .` to build the project and install the CLI

Currently, only `linux/amd64` with `AVX` is supported.

## Usage

### Prove

- Generate a proof for a Cairo 0 or Cairo 1 program
- `stone-cli prove --cairo_program <program-path>`
- Additional args:
  - `--program_input`
  - `--program_input_file`
  - `--layout`
  - `--prover_config_file`
  - `--parameter_file`
  - `--output`
- Additional args for prover parameters:
  - `--field`
  - `--channel_hash`
  - `--commitment_hash`
  - `--n_verifier_friendly_commitment_layers`
  - `--pow_hash`
  - `--page_hash`
  - `--fri_step_list`
  - `--last_layer_degree_bound`
  - `--n_queries`
  - `--proof_of_work_bits`
  - `--log_n_cosets`
  - `--use_extension_field`
  - `--verifier_friendly_channel_updates`
  - `--verifier_friendly_commitment_hash`
- Additional args for prover config:
  - `--store_full_lde`
  - `--use_fft_for_eval`
  - `--constraint_polynomial_task_size`
  - `--n_out_of_memory_merkle_layers`
  - `--table_prover_n_tasks_per_segment`

### Prove bootloader

- Generate a proof for the bootloader Cairo program
- `stone-cli prove --cairo_program <program-path>`
- Additional args:
  - `--program_input`
  - `--program_input_file`
  - `--layout`
  - `--prover_config_file`
  - `--parameter_file`

### Verify

- Verify a proof generated by the prover
- `stone-cli verify --proof <proof-path>`
- Additional args:
  - `--annotation_file`
  - `--extra_output_file`

### Serialize Proof

- Serialize a proof to a file
- `stone-cli serialize-proof --proof <proof-path> --network <network> --output <output-path>`
- Additional args:
  - `--annotation_file`
  - `--extra_output_file`

Using `--network starknet` serializes the Cairo proof into a format that can be verified on the Cairo verifier deployed on Starknet. Please refer to the [integrity documentation](https://github.com/HerodotusDev/integrity) for more information on how to use the calldata to send a transaction to Starknet.

Using `--network ethereum` serializes the Cairo proof into a format that can be verified on the Cairo verifier deployed on Ethereum. Please refer to the [the next section](#how-to-create-proofs-and-verify-them-on-ethereum) for more information on how to create proofs that can be verified on Ethereum.

### How to create proofs and verify them on Ethereum

Currently there is a Cairo verifier deployed on Ethereum, which are mainly used to verify SHARP proofs created by L2 Starknet nodes. The Cairo verifier checks the validity of a Cairo program named `bootloader`, which recursively verifies multiple Cairo programs or a Cairo PIEs (Position Independent Executable) and allows a single proof to prove executions of multiple Cairo programs. Once we create a bootloader proof, we need to serialize it to a format that works for the Cairo verifier on Ethereum.

Here are the specific steps for the above process:

1. Call `stone-cli prove-bootloader --cairo_programs ./examples/cairo0/bitwise_output.json --layout starknet --parameter_file ./tests/configs/bootloader_cpu_air_params.json --output bootloader_proof.json --fact_topologies_output fact_topologies.json`

   - Can also provide multiple programs and pies by providing a space-separated list of paths

2. Call `stone-cli verify --proof bootloader_proof.json --annotation_file annotation.json --extra_output_file extra_output.json`

3. Call `stone-cli serialize-proof --proof bootloader_proof.json --annotation_file annotation.json --extra_output_file extra_output.json --network ethereum --output bootloader_serialized_proof.json`

4. Verify on Ethereum with the [evm-adapter CLI](https://github.com/zksecurity/stark-evm-adapter/tree/add-build-configs?tab=readme-ov-file#using-existing-proof) using the `bootloader_serialized_proof.json` and `fact_topologies.json` files as inputs

#### Notes

- Cairo 0 programs that use hints are not supported
- Only the `starknet` layout is supported for bootloader proofs
- Programs should use the `output` builtin--programs that do not can be proved, but won't verify on Ethereum

## Additional Resources

### List of supported builtins per layout

| Layout      | dex | recursive | recursive_with_poseidon | small | starknet | starknet_with_keccak |
| ----------- | :-: | :-------: | :---------------------: | :---: | :------: | :------------------: |
| output      |  O  |     O     |            O            |   O   |    O     |          O           |
| pedersen    |  O  |     O     |            O            |   O   |    O     |          O           |
| range_check |  O  |     O     |            O            |   O   |    O     |          O           |
| bitwise     |  O  |     O     |            O            |       |    O     |          O           |
| ecdsa       |  O  |           |                         |       |    O     |          O           |
| poseidon    |     |           |            O            |       |          |                      |
| ec_op       |     |           |                         |       |    O     |          O           |
| keccak      |     |           |                         |       |          |          O           |
