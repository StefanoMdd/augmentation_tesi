#!/bin/bash


#### one file at time, not parallelized



# Check if the input directory is provided
# if [ "$#" -ne 1 ]; then
#     echo "Usage: $0 <input_directory>"
#     exit 1
# fi

source /home/stefano/miniforge3/etc/profile.d/conda.sh
conda activate augmentation_env

# input_dir="$1"
input_dir="/home/stefano/projects/augmentation_tesi/OASIS_TEST"
output_base="/home/stefano/projects/augmentation_tesi/output"

# Find all .nii.gz files in the input directory recursively
find "$input_dir" -type f -name "*.nii.gz" | while read -r file; do
    # Extract the relative directory path from the input file
    relative_dir=$(dirname "${file#$input_dir/}")
    
    # Create the corresponding output directory
    output_dir="$output_base/$relative_dir"
    mkdir -p "$output_dir"
    
    # Extract the base filename without extension
    base_filename=$(basename "$file" .nii.gz)
    

    # Define the output and temporary file paths
    temp1_file="$output_dir/${base_filename}_temp1.nii.gz"
    temp2_file="$output_dir/${base_filename}_temp2.nii.gz"
    temp3_file="$output_dir/${base_filename}_temp3.nii.gz"
    output_file="$output_dir/${base_filename}_processed.nii.gz"

    # Call the Python script with the input and temporary file paths
    cd /home/stefano/projects/augmentation_tesi/scripts/
    printf "\nNow: python preprocessing.py \n\t$file \n\t--> $temp1_file \n"
    python3 preprocessing.py "$file" "$temp1_file"

    # Run flirt process
    printf "\nNow: flirt \n\t$temp1_file \n\t--> $temp2_file \n"
    # /home/stefano/fsl/bin/flirt -in $temp1_file -ref "../templates/MNI152_T1_1mm.nii.gz" -out $temp2_file -omat ${output_dir}/invol2refvol.mat -dof 9
    flirt -in $temp1_file -ref "../templates/MNI152_T1_1mm.nii.gz" -out $temp2_file -omat ${output_dir}/invol2refvol.mat -dof 9

    # Run bet process
    printf "\nNow: bet \n\t$temp2_file \n\t--> $temp3_file \n"
    # /home/stefano/fsl/bin/bet $temp2_file $output_file -R
    bet $temp2_file $temp3_file -R

    printf "\nNow: python resize.py \n\t$temp3_file \n\t--> $output_file\n"
    python3 resize.py "$temp3_file" "$output_file"

    # NORMALIZATION QUI
    
    # Remove temporary files
    rm -f "$temp1_file" "$temp2_file" "$temp3_file"
done

echo "    FINITO   "