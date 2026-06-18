import os
import torch
import numpy as np
from PIL import Image
from monai.bundle import ConfigParser

def run_local_file_pipeline():
    device = torch.device("cpu")
    
    # 1. Grab the file path from the environment variable
    image_path = os.getenv("LOCAL_TEST_IMAGE_PATH", "/app/test_image/sample_cell.png")
    
    if not os.path.exists(image_path):
        raise FileNotFoundError(f"Could not find test image at: {image_path}")

    # 2. Read the image and convert it to grayscale or RGB
    print(f"Reading input image file: {image_path}")
    raw_img = Image.open(image_path).convert("RGB")
    raw_array = np.array(raw_img).astype(np.float32) / 255.0  # Normalize to [0, 1]
    
    # Resize to 128x128 to match NuClick input expectations
    # In a production app, you would use MONAI's 'Resize' transform here instead
    from skimage.transform import resize
    resized_img = resize(raw_array, (128, 128, 3), anti_aliasing=True)
    
    # Transpose from [Height, Width, Channels] to [Channels, Height, Width]
    # Then add a batch dimension: [Batch, Channels, Height, Width] -> [1, 3, 128, 128]
    img_tensor = torch.tensor(resized_img).permute(2, 0, 1).unsqueeze(0).float()

    # 3. Create the 4th Channel: The Click Map
    # For testing, we simulate a click dead-center at coordinate (64, 64)
    click_map = torch.zeros((1, 1, 128, 128), dtype=torch.float32)
    click_map[0, 0, 64, 64] = 1.0

    # Combine into a 4-channel input array
    input_tensor = torch.cat([img_tensor, click_map], dim=1).to(device)

    # 4. Run through the model
    bundle_dir = "/app/bundle/pathology_nuclick_annotation"
    parser = ConfigParser()
    parser.read_config(os.path.join(bundle_dir, "configs", "inference.json"))
    network = parser.get_parsed_content("network").to(device)
    network.eval()

    with torch.no_grad():
        output = network(input_tensor)
        mask = (torch.sigmoid(output) > 0.5).cpu().numpy().astype(np.uint8)
    
    print(f"🎉 Success! Found mask with {np.sum(mask)} segmented nucleus pixels.")

if __name__ == "__main__":
    run_local_file_pipeline()