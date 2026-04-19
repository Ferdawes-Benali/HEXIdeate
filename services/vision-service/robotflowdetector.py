# 1. Import the library
from inference_sdk import InferenceHTTPClient

# 2. Connect to your workspace
client = InferenceHTTPClient(
  api_url="https://serverless.roboflow.com",
  api_key="x15*****************"
)

# 3. Run your workflow on an image
result = client.run_workflow(
  workspace_name="meriam-cherif",
  workflow_id="<YOUR_WORKFLOW_ID>",
  images={
    "image": "YOUR_IMAGE.jpg"  # Path to your image file
  },
  parameters={
    "classes": "capsules, tablets"
  },
  use_cache=True  # cache workflow definition for 15 minutes
)

# 4. Get your results
print(result)