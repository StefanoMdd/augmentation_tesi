#!/bin/bash
starttime=`date +%s`

echo " Starting... ${date +'%Y-%m-%d : %H:%M'}"

# Check if GNU Parallel is installed
if ! command -v parallel &> /dev/null; then
    echo "GNU Parallel is not installed. Please install it and try again."
    exit 1
fi

source /home/stefano/miniforge3/etc/profile.d/conda.sh
conda activate augmentation_env

# input_dir="/home/stefano/projects/augmentation_tesi/OASIS_TEST"
# input_dir="/home/stefano/projects/augmentation/dataset/traghetto2/data"
# # output_base="/home/stefano/projects/augmentation_tesi/output"
# output_base="/home/stefano/output_oasis3_processed"

input_dir="/home/stefano/OASIS3_FULLDATASET/data"
output_base="/home/stefano/output_oasis3_processed"


# Define the processing function
process_file() {
    local file="$1"
    local input_dir="$2"
    local output_base="$3"

    # Extract the relative directory path from the input file
    local relative_dir
    relative_dir=$(dirname "${file#$input_dir/}")

    # Create the corresponding output directory
    local output_dir="$output_base/$relative_dir"
    mkdir -p "$output_dir"

    # Extract the base filename without extension
    local base_filename
    base_filename=$(basename "$file" .nii.gz)

    # Define the output and temporary file paths
    local temp1_file="$output_dir/${base_filename}_temp1.nii.gz"
    local temp2_file="$output_dir/${base_filename}_temp2.nii.gz"
    local temp3_file="$output_dir/${base_filename}_temp3.nii.gz"
    local output_file="$output_dir/${base_filename}_processed.nii.gz"

    # Call the Python script with the input and temporary file paths
    cd /home/stefano/projects/augmentation_tesi/scripts/
    printf "\nNow: python preprocessing.py \n\t$file \n\t--> $temp1_file \n"
    python3 preprocessing.py "$file" "$temp1_file"

    # Run flirt process
    printf "\nNow: flirt \n\t$temp1_file \n\t--> $temp2_file \n"
    flirt -in "$temp1_file" -ref "../templates/MNI152_T1_1mm.nii.gz" -out "$temp2_file" -omat "${output_dir}/invol2refvol.mat" -dof 9

    # Run bet process
    printf "\nNow: bet \n\t$temp2_file \n\t--> $temp3_file \n"
    bet "$temp2_file" "$temp3_file" -R

    printf "\nNow: python res_norm.py \n\t$temp3_file \n\t--> $output_file\n"
    python3 res_norm.py "$temp3_file" "$output_file"

    # Remove temporary files
    rm -f "$temp1_file" "$temp2_file" "$temp3_file"
}

export -f process_file

# Find all .nii.gz files and process them in parallel
find "$input_dir" -type f -name "*.nii.gz" | parallel process_file {} "$input_dir" "$output_base"


endtime=`date +%s`

printf " FINITO... ${date +'%Y-%m-%d : %H:%M'}"


echo Execution time was `expr ${endtime} - ${starttime}` seconds.