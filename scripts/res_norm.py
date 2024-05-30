import sys
#import scipy
import ants

def main(input_file, output_file):

    # scipy.ndimage.zoom(

    # Read the input image
    image = ants.image_read(input_file) #.numpy()
    
   # image2 = scipy.ndimage.zoom(input=image, zoom=0.5) #, output=None, order=3, mode='constant', cval=0.0, prefilter=True, *, grid_mode=False)


    image2 = ants.resample_image(image,(91,109,91),1,4)

    #z-normalization
    image3 = (image2.numpy() - image2.mean()) / image2.std()

    #Create a new ANTsImage with the same header information, but with a new image array
    image4 = image2.new_image_like(image3)
    

    ants.image_write(image4, output_file, ri=False)



if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python process_nii.py <input_file> <output_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    main(input_file, output_file)