import torch

if torch.cuda.is_available():
    print("GPU Disponible: ", torch.cuda.get_device_name(0))
else:
    print("No hay GPU, se usara CPU")
