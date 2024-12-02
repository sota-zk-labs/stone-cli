# generate bootloader proof

stone-cli prove-bootloader --cairo_pies ./examples/cairo_pie/fibonacci_with_output.zip \
--layout starknet --parameter_file ./tests/configs/bootloader_cpu_air_params.json \
--output bootloader_proof.json --fact_topologies_output fact_topologies.json \

# verify proof => annotation file and extra output

stone-cli verify --proof bootloader_proof.json --annotation_file annotation.json --extra_output_file extra_output.json \
--stone_version v5

# serialize proof
stone-cli serialize-proof --proof bootloader_proof.json --annotation_file annotation.json \
--extra_output_file extra_output.json --network ethereum --output bootloader_serialized_proof.json