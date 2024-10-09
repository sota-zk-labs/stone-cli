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

`--annotation_file` and `--extra_output_file` arguments are required when serializing a proof for Ethereum.

### Serialize Proof

- Serialize a proof to be verified on Starknet or Ethereum
- Ethereum
  - `stone-cli serialize-proof --proof <proof-path> --network ethereum --annotation_file <annotation-path> --extra_output_file <extra-output-path> --output <output-path>`
- Starknet
  - [integrity](https://github.com/HerodotusDev/integrity) provides two types of serializations for Starknet
  - monolith type (supports only `recursive` layout)
    - `stone-cli serialize-proof --proof <proof-path> --network starknet --serialization_type monolith --output <output-path>`
  - split type (supports `dex`, `small`, `recursive`, `recursive_with_poseidon`, `starknet`, and `starknet_with_keccak` layouts)
    - `stone-cli serialize-proof --proof <proof-path> --network starknet --serialization_type split --output_dir <output-dir> --layout starknet`

### How to create proofs and verify them on Ethereum

Currently there is a Solidity verifier deployed on Ethereum, which is mainly used to verify SHARP proofs created by L2 Starknet nodes. The Solidity verifier checks the validity of a Cairo program named `bootloader`, which can prove the execution of multiple Cairo programs or Cairo PIEs (Position Independent Executable) either by executing them directly in the program or by running a Cairo verifier that recursively verifies (i.e. verify a proof inside the program) a bootloader proof. The bootloader program dramatically lowers the cost of verification as proving a new Cairo program will grow the size of the proof logarithmically as opposed to linearly. Once we create a bootloader proof, we need to serialize it to a format that works for the Cairo verifier on Ethereum. (Note: Recursive verification is not supported yet)

Here are the specific steps for the above process:

1. Call `stone-cli prove-bootloader --cairo_programs ./examples/cairo0/bitwise_output.json --layout starknet --parameter_file ./tests/configs/bootloader_cpu_air_params.json --output bootloader_proof.json --fact_topologies_output fact_topologies.json`

   - Can also provide multiple programs and pies by providing a space-separated list of paths

2. Call `stone-cli verify --proof bootloader_proof.json --annotation_file annotation.json --extra_output_file extra_output.json`

3. Call `stone-cli serialize-proof --proof bootloader_proof.json --annotation_file annotation.json --extra_output_file extra_output.json --network ethereum --output bootloader_serialized_proof.json`

4. Verify on Ethereum with the [evm-adapter CLI](https://github.com/zksecurity/stark-evm-adapter/tree/add-build-configs?tab=readme-ov-file#using-existing-proof) using the `bootloader_serialized_proof.json` and `fact_topologies.json` files as inputs

### How to create proofs and verify them on Starknet

1. Call `stone-cli prove --cairo_program <program-path> --layout <layout>` with a layout that is supported by either the `monolith` or `split` serialization types

2. Call `stone-cli serialize-proof --proof <proof-path> --network starknet --serialization_type monolith --output <output-path>` or `stone-cli serialize-proof --proof <proof-path> --network starknet --serialization_type split --output_dir <output-dir> --layout <layout>`

3. Verify on Starknet with [integrity](https://github.com/HerodotusDev/integrity) using the `output` file or files in the `output_dir` as input

#### Notes

- Cairo 0 programs that use hints are not supported
- Only the `starknet` layout is supported for bootloader proofs
- Programs should use the `output` builtin--programs that do not can be proved, but won't verify on Ethereum

## Additional Resources

### List of supported builtins per layout

|             | small | recursive | dex | recursive_with_poseidon | starknet | starknet_with_keccak |
| ----------- | :---: | :-------: | :-: | :---------------------: | :------: | :------------------: |
| output      |   O   |     O     |  O  |            O            |    O     |          O           |
| pedersen    |   O   |     O     |  O  |            O            |    O     |          O           |
| range_check |   O   |     O     |  O  |            O            |    O     |          O           |
| bitwise     |       |     O     |     |            O            |    O     |          O           |
| ecdsa       |       |           |  O  |                         |    O     |          O           |
| poseidon    |       |           |     |            O            |    O     |          O           |
| ec_op       |       |           |     |                         |    O     |          O           |
| keccak      |       |           |     |                         |          |          O           |

### Commands diagram

![Commands Diagram](./assets/commands-diagram.svg)
