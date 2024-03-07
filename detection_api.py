import logging
from fastapi import FastAPI, File, UploadFile, Request, Path, HTTPException
from typing import List
from PIL import Image
import matplotlib.pyplot as plt
import json
import io
from pydantic import BaseModel
from fastapi import HTTPException
from typing import Dict
from utils import search,choose_and_crop

app = FastAPI()

global content
content = None

class Item(BaseModel):
    name: str


@app.post("/send_data")
async def send_data(item: Item):
    print(f"Username: {item.name}")
    logging.info("Username: %s", item.name)
    return {}


@app.post("/uploadImage/{username}")
async def upload_image(username: str, image: UploadFile = File(...)):
    # print(f"Received image for username: {username}")
    global content  # Use the global variable

    content = await image.read()
    image_pil = Image.open(io.BytesIO(content))
    # Display the received image using matplotlib
    # plt.imshow(image_pil)
    # plt.title(f"Received image for username: {username}")
    # plt.axis("off")
    # plt.show()
    
    yolo_output = choose_and_crop(image_pil)
    print(yolo_output)
    return {"yolo output":yolo_output}




@app.post("/search/")
async def search_endpoint(data: Dict[str, List[int]]):
    try:
        global content  # Use the global variable
        if content is None:
            print("Image content is missing")
            raise HTTPException(status_code=500, detail="Image content is missing")


        coordinates = data

        print(f"Bounding Box Coordinates: {coordinates}")
        

        
        df = search(content,coordinates,6)

        df_json = df.to_json(orient='records')
        df_response = json.loads(df_json)
        print(df_response)
        return {"results": df_response}
    except Exception as e:
        # Handle any errors that may occur
        raise HTTPException(status_code=500, detail=f"Error processing request: {str(e)}")

