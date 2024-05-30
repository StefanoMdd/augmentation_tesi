import sys
import ants

def main(input_file, output_file):
    # Read the input image
    image = ants.image_read(input_file)
    
    # Perform N4 bias field correction
    image2 = ants.n4_bias_field_correction(image)
    
    # Write the processed image to the output file
    ants.image_write(image2, output_file, ri=False)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python process_nii.py <input_file> <output_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    main(input_file, output_file)