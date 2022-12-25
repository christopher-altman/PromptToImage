# PromptToImage
Swift/AppKit CoreML Stable Diffusion app for macOS
<img width="720" alt="pti" src="https://user-images.githubusercontent.com/27217431/209454286-9f343a69-a32c-49bd-abe8-2425f67ef309.png">

# Features
- Negative Prompt
- Guidance Scale
- Multiple Images
- Image to Image
- Custom user-defined models
- History
- 4x Upscaler (CoreML Real esrgan)
- save image with EXIF metadata
- sandboxed

# Download App
Public beta available though TestFlight. Requires valid Apple ID.
Beta includes Stable Diffusion 2.1 model.<br>
Link: coming soon

# System Requirements
Requires an Apple Silicon Mac running macOS 13.1 Ventura<br>
Intel Macs not supported.

# ML Models
This GitHub repo does not include CoreML models.<br>
You can find CoreML models designed for this app here:
https://huggingface.co/TheMurusTeam<br>
Learn how to convert Stable Diffusion models to CoreML format here: https://github.com/apple/ml-stable-diffusion

# Performances and energy
For best performance on M1 and M2:<br>
model: Stable Diffusion 2.1 SPLIT EINSUM, compute units: CPU and Neural Engine<br>
For best performance on M1Pro, M1Max and M1 Ultra:<br>
model: Stable Diffusion 2.1 ORIGINAL, compute units: CPU and GPU<br>

On Apple Silicon Macs with 24 or more GPU cores the "CPU and GPU" is by far the fastest, however, due to the high energy consumption of the GPU, if you generate more than 10 images at once, laptop fans will spin and fanless laptops will throttle. To drastically reduce power consumption you should use the default model and "CPU and Neural Engine" compute units.<br>

# Benchmarks 
MacBook Pro 14" M1Max 32Gb RAM (macOS 13.1):
- Stable Diffusion 2.1 SPLIT EINSUM, CPU and Neural Engine:  1.8 step/sec,   3.5 Watt
- Stable Diffusion 2.1 SPLIT EINSUM, CPU and GPU:            1.95 step/sec,  21.5 Watt
- Stable Diffusion 2.1 SPLIT EINSUM, All compute units:      2.2 step/sec,   11 Watt
- Stable Diffusion 2.1 ORIGINAL, CPU and GPU:                2.7 step/sec,   28 Watt


# Privacy
This is a sanboxed app. It is not allowed to access your personal files and data. Everything runs locally, nothing is sent to the network. None of your data is collected. 

# Build 
To build this app you need an Apple Silicon Mac running macOS 13 Ventura 13.1 or later, and Xcode 14.2 or later.<br>
The Xcode project does not include the default CoreML model and accessory files. You need to add these files to the main project folder within Xcode before building. It's mandatory to use a specific model, as the app expects only this model to be installed in the app bundle. These files list includes:<br>
Upscaler model file:<br>
- realesrgan512.mlmodel: under [PromptToImage/Upscale Model](PromptToImage/Upscale%20Model)<br>

CoreML-Stable-Diffusion-2.1-SPLIT_EINSUM-img2img model files:<br>
- merges.txt: under [PromptToImage/Stable Diffusion Resources](PromptToImage/Stable%20Diffusion%20Resources)
- vocab.json: under [PromptToImage/Stable Diffusion Resources](PromptToImage/Stable%20Diffusion%20Resources)
- TextEncoder.mlmodelc: under [PromptToImage/Stable Diffusion Resources](PromptToImage/Stable%20Diffusion%20Resources)
- Unet.mlmodelc: under [PromptToImage/Stable Diffusion Resources](PromptToImage/Stable%20Diffusion%20Resources)
- VAEDecoder.mlmodelc: under [PromptToImage/Stable Diffusion Resources](PromptToImage/Stable%20Diffusion%20Resources)
- VAEEncoder.mlmodelc (optional, required for img2img): under [PromptToImage/Stable Diffusion Resources](PromptToImage/Stable%20Diffusion%20Resources)<br><br>
You can get both uspcaler and stable diffusion models here: https://huggingface.co/TheMurusTeam


