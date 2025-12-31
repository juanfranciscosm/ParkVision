import torch
print(torch.cuda.is_available())
print(torch.cuda.get_device_name(0) if torch.cuda.is_available() else "No GPU")

# Si se esta usando GPU Nvidia deberia salir: 
# True
# NVIDIA GeForce RTX ...
