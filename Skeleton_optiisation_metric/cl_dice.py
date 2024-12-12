import SimpleITK as sitk
import numpy as np
from skimage.morphology import skeletonize, skeletonize_3d, remove_small_holes 
import tifffile
from skimage.measure import euler_number, label, regionprops_table
import matplotlib.pyplot as plt
import pandas as pd
import glob, os

# this works with environment registration_env.

def read_in_image_stack(tiff_stack_path):
# Path to the multipage 3D TIFF stack

    # Open the TIFF stack using the tiffile library
    with tifffile.TiffFile(tiff_stack_path) as tif:
    # Read all pages (slices) in the TIFF stack
        tiff_data = tif.asarray()

    # Display a slice from the 3D TIFF stack
    slice_index = 50  # Index of the slice to display
    plt.imshow(tiff_data[slice_index], cmap='gray')
    plt.title(f"Slice {slice_index}")
    plt.axis('off')
    plt.show()

    return tiff_data

def calc_region_props(v):
       v=remove_small_holes(v,area_threshold=10)
       label_im = label(v)
       plt.imshow(label_im[50,:,:])
       plt.show()
       #regions=regionprops(label_im)
       regions = regionprops_table(label_im, properties=('area','label','euler_number'))
       return regions
      

def cl_score(v, s):
    """[this function computes the skeleton volume overlap]

    Args:
        v ([bool]): [image]
        s ([bool]): [skeleton]

    Returns:
        [float]: [computed skeleton volume intersection]
    """
    v=np.divide(v,255)
    s=np.divide(s,255)
    #print(np.sum(v*s))
    #print(np.sum(s))
    return np.sum(v*s)/np.sum(s)

def Dice(v_p,v_l):
    intersection = np.sum(v_l & v_p)
    dice = (2.0 * intersection) / (np.sum(v_l) + np.sum(v_p))
    return dice

def clDice(v_p, v_l):
    """[this function computes the cldice metric]

    Args:
        v_p ([bool]): [predicted image]
        v_l ([bool]): [ground truth image]

    Returns:
        [float]: [cldice metric]
    """
    if len(v_p.shape)==2:
        tprec = cl_score(v_p,skeletonize(v_l))
        tsens = cl_score(v_l,skeletonize(v_p))
    elif len(v_p.shape)==3:
        print('skeletonising 3d')
        tprec = cl_score(v_p,skeletonize_3d(v_l))
        tsens = cl_score(v_l,skeletonize_3d(v_p))
    return 2*tprec*tsens/(tprec+tsens)

def clDice_wskel(v_p, s_p,v_l,s_l):
    """[this function computes the cldice metric]

    Args:
        v_p ([bool]): [predicted image]
        s_p ([bool]): [predicted skeleton]
        v_l ([bool]): [ground truth image]
        s_l ([bool]): [ground truth skeleton]

    Returns:
        [float]: [cldice metric]
    """
    
    print
    if len(v_p.shape)==2:
        tprec = cl_score(v_p,s_l)
        tsens = cl_score(v_l,s_p)
    elif len(v_p.shape)==3:
        print('skeletonising 3d')
        tprec = cl_score(v_p,s_l)
        tsens = cl_score(v_l,s_p)
        print(tprec,tsens)
    return 2*tprec*tsens/(tprec+tsens)

def clSens_wskel(v_l,s_p):
    """[this function computes the cldice sensitivity metric]

    Args:
        v_p ([bool]): [predicted image]
        s_p ([bool]): [predicted skeleton]
        v_l ([bool]): [ground truth image]
        s_l ([bool]): [ground truth skeleton]

    Returns:
        [float]: [cldice metric]
    """
    
    print
    if len(v_l.shape)==2:
        tsens = cl_score(v_l,s_p)
    elif len(v_l.shape)==3:
       # print('skeletonising 3d')
        tsens = cl_score(v_l,s_p)
       # print(tsens)
    return tsens

def main():
    print('loading data')
    
    
    
    g_t_im_path= r'F:\Dropbox (UCL)\Dropbox (UCL)\HiP-CT_Claire_analysis\LADAF-2021-17\Topology_paper\Skeletonisation_raw_data\50um-LADAF-2021-17_labels_finalised_2.tif'
    v_l=read_in_image_stack(g_t_im_path);
    #g_t_im_path= r'F:\Dropbox (UCL)\Dropbox (UCL)\HiP-CT_Claire_analysis\LADAF-2021-17\kidney\multi_scale_overlap_dice\skeleton_13um.tif'
    #s_l=read_in_image_stack(g_t_im_path);
    
   # pred_im_path=r'F:\Dropbox (UCL)\Dropbox (UCL)\Hannah_Claire_vessel_comps\HREM\Medulla_network\Consensus_optimisation\1st_iteration\VesselVio_binarized_resized.tif'
    #v_p=read_in_image_stack(pred_im_path)
    
    pred_im_path=r"F:\Dropbox (UCL)\Dropbox (UCL)\HiP-CT_Claire_analysis\LADAF-2021-17\Topology_paper\Skeleton_optimisation"
    os.chdir(pred_im_path)
    d=[]
    for file in glob.glob("*converted.tif"):
        print(file)
        s_p=read_in_image_stack(file)
       # print(v_p.shape,s_p.shape)
    #s_p=s_p[15:s_p.shape[0]-15,15:s_p.shape[1]-15,15:s_p.shape[2]-15]   # 15 pxl padding is added during skeletonisation using amira autoskeleton, this should be removed before c_l_dice calcs.
    #print(v_l.shape, s_l.shape)
    #print(v_p.shape,s_p.shape)
    #s_l=s_l[15:s_l.shape[0]-15,15:s_l.shape[1]-15,15:s_l.shape[2]-15]
    #print(v_l.shape, s_l.shape)

        if v_l.shape!=s_p.shape:
            print('skeleton and label do not have matching size this is not going to end well!!!')
   # print('computing cl_dice_')
   # region_v_l=calc_region_props(v_l)
    #data_v_l=pd.DataFrame(region_v_l)
   # print('saving region props')
    #data_v_l.to_csv("F:\Dropbox (UCL)\Dropbox (UCL)\Hannah_Claire_vessel_comps\HREM\FADUS\Consensus_evaluation_fadu\STAPLE_Result_FADU_regionprops.csv", encoding='utf-8', index=False)
    #region_v_p=calc_region_props(v_p)
    #data_v_p=pd.DataFrame(region_v_p)
    #data_v_p.to_csv(r'F:\Dropbox (UCL)\Dropbox (UCL)\Hannah_Claire_vessel_comps\HREM\FADUS\Consensus_evaluation_fadu\STAPLE_Result_FADU_CL_regionprops.csv', encoding='utf-8', index=False)

   # display(data_v_p)
        print('computing dice')
        cl_sense=clSens_wskel(v_l,s_p)
        print(cl_sense)
        d.append(
            {'Name':file, 'Cl_sense':cl_sense}
        )
   # cldice_score=clDice_wskel(v_p,s_p, v_l,s_l)
        
    #dice_score=Dice(v_p,v_l)
    #print(cldice_score, dice_score)
        
    output=pd.DataFrame(d)
    output.to_csv(os.path.join(pred_im_path,'cl_sensitivity_result.csv'), encoding='utf-8', index=False)
if __name__ == "__main__":
    main()