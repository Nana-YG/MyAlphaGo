#!/bin/bash

# Shell script to process SGF files into HDF5 format
# For 'test', 'train', and 'val' datasets

# Directories
INPUT_BASE_DIR="./Dataset/sgf"    # Input SGF root directory
OUTPUT_BASE_DIR="./Dataset/h5"    # Output HDF5 root directory
GTP_CORE_EXEC="./cpp/GTP-Core/cpp/build/GTP-Core" # Path to GTP-Core executable

# Ensure GTP-Core exists
if [[ ! -f "$GTP_CORE_EXEC" ]]; then
    echo "Error: GTP-Core executable not found at $GTP_CORE_EXEC"
    exit 1
fi

# Function to process SGF files in a directory
process_sgf_dir() {
    local input_dir=$1
    local output_dir=$2

    # Ensure output directory exists
    mkdir -p "$output_dir"

    # Loop through subdirectories (0000, 0001, etc.)
    for folder in "$input_dir"/*; do
        if [[ -d "$folder" ]]; then
            folder_name=$(basename "$folder")
            output_sub_dir="$output_dir/$folder_name"
            mkdir -p "$output_sub_dir"

            echo "Processing folder: $folder -> $output_sub_dir"
            echo "Converting $folder -> $output_sub_dir"
            "$GTP_CORE_EXEC" ReadData "$folder" "$output_sub_dir"
        fi
    done
}

# Function to clean all HDF5 files
clean_hdf5() {
    echo "Cleaning all HDF5 files in $OUTPUT_BASE_DIR..."
    find "$OUTPUT_BASE_DIR" -type f -name "*.h5" -delete
    echo "All HDF5 files have been removed."
}

# Main script logic
case "$1" in
    clean)
        clean_hdf5
        ;;
    process)
        echo "Starting SGF to HDF5 conversion..."
        process_sgf_dir "$INPUT_BASE_DIR/test" "$OUTPUT_BASE_DIR/test"
        process_sgf_dir "$INPUT_BASE_DIR/train" "$OUTPUT_BASE_DIR/train"
        process_sgf_dir "$INPUT_BASE_DIR/val" "$OUTPUT_BASE_DIR/val"
        echo "SGF to HDF5 conversion completed successfully."
        ;;
    *)
        echo "Usage: $0 {process|clean}"
        echo "  process  - Convert SGF files to HDF5 format"
        echo "  clean    - Remove all HDF5 files"
        exit 1
        ;;
esac