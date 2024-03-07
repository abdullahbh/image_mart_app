import numpy as np
import pandas as pd
from PIL import Image
import matplotlib.pyplot as plt
import torch
import faiss
import cv2
from transformers import AutoImageProcessor, Dinov2Model
from ultralytics import YOLO
import io

yolo_weights = "C:/Users/Aeiman Imtiaz/OneDrive/Desktop/University Work/API/yolo_weights.pt"
## Reading files

index = faiss.read_index('C:/Users/Aeiman Imtiaz/OneDrive/Desktop/University Work/API/dinoIndex_gd.bin')
df = pd.read_csv('C:/Users/Aeiman Imtiaz/OneDrive/Desktop/University Work/API/urls.csv')

## Loading models
processor_dino = AutoImageProcessor.from_pretrained("facebook/dinov2-base")
model_dino = Dinov2Model.from_pretrained("facebook/dinov2-base")



## Feature extractor
def dinoFeatureExtractor(cropped_image):
    """
    Extract features from a cropped image using the DINO model.

    Parameters:
    - cropped_image (PIL.Image): The cropped region of an image.

    Returns:
    - torch.Tensor: Extracted image features.
    """
    query_inputs = processor_dino(images=cropped_image, return_tensors="pt")
    with torch.no_grad():
      query_image_features = model_dino(**query_inputs)
      image_features = query_image_features.last_hidden_state
      image_features = image_features.mean(dim=1)
      return image_features
  
  
    
def query(image_features,k):
    
    """
    Perform a query using image features and retrieve similar images.

    Parameters:
    - image_features (torch.Tensor): Image features to query.
    - k (int): Number of similar images to retrieve.
    - organized_images_path (str): Path to the Catalog images directory.

    Returns:
    - pd.DataFrame: DataFrame containing query results.
    
    """
    query_features = image_features.squeeze().numpy()

    with torch.no_grad():
        distances, indices = index.search(np.expand_dims(query_features, axis=0).astype(np.float32), 15)

    dino_df = pd.DataFrame({
        'image name': df['image name'].iloc[indices[0]],
        'label' : df['label'].iloc[indices[0]],
        'distance': distances[0],
        'url':df['Image_Url'].iloc[indices[0]]
    })

    dino_df['product_id'] = dino_df['image name'].str.split('_', n=1).str[0]
    dino_df = dino_df.drop_duplicates(subset=['product_id'])
    dino_df = dino_df.drop(columns=['product_id'])
    dino_df = dino_df[:k]
    return dino_df
    
## Searching
def search(image,coordinates,k):
    """
    Perform a search based on a cropped region of an image.

    Parameters:
    - image_path (str): Path to the original image.
    - coordinates (tuple): Bounding box coordinates (x1, y1, x2, y2).

    Returns:
    - pd.DataFrame: DataFrame containing search results.
    
    """
    x1, y1, x2, y2 = coordinates['coordinates']
    image1 = Image.open(io.BytesIO(image))
    cropped_region = image1.crop((x1, y1, x2, y2))
    image_features = dinoFeatureExtractor(cropped_region)
    df = query(image_features,k)
    return df
    

  

# Variable to store information based on user choice
chosen_object_info = None
image_path = None  # Define image_path globally

def choose_and_crop(image):
    """
    Choose and crop objects in an image using YOLO.

    Parameters:
    - image: user uploaded image.

    Returns:
    - dict: Dictionary containing information about bounding boxes.
    """
    
    model = YOLO(yolo_weights)
    results = model(image)
    for result in results:
        im_array = result.plot()
        im_rgb = im_array[..., ::-1]
        # plt.figure(figsize=(12, 8))
        # plt.imshow(im_rgb)
        # plt.show()

    bounding_boxes = [
        {"Index": i,
         "label": model.names[int(box.cls.item())],
         "confidence": f"{float(box.conf[0].cpu().numpy()):.2f}",
         "coordinates": box.xyxy[0, :4].cpu().numpy().astype(int).tolist()
        }
        for i, box in enumerate(results[0].boxes)
    ]

    return bounding_boxes

