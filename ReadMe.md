# 🎬 Codec Converter for DaVinci Resolve

A Bash script that batch-converts video files to the Apple ProRes (prores_ks) video codec and PCM (pcm_s16le) audio codec, ensuring compatibility with DaVinci Resolve. This tool is especially useful for filmmakers, video editors, and content creators needing a quick codec fix for smoother editing in DaVinci.
## 📁 Features

    ✅ Converts .mp4 videos to .mov using prores_ks + pcm_s16le

    ✅ Automatically adjusts resolution based on video orientation:

        Portrait: 1080x1920

        Landscape: 1920x1080

    ✅ Supports single file or batch processing from a directory

    ✅ Maintains output in a changed/ subfolder

## ⚙️ Requirements

    ffmpeg

    ffprobe

    Bash shell (Linux/macOS environment)

Install ffmpeg and ffprobe via your package manager:

```bash
sudo apt install ffmpeg   # Debian/Ubuntu
brew install ffmpeg       # macOS (Homebrew)
```


## 🚀 Usage

Make the script executable:

```bash
chmod +x convert.sh
```

Convert a single file:

```bash
./convert.sh your_video.mp4
```

Convert all .mp4 files in a folder:

```bash
./convert.sh your_folder/
```

Converted files will be saved in a new folder named changed/ inside the specified directory.
🛠 How It Works

    Detects resolution using ffprobe.

    Scales to appropriate dimensions (portrait/landscape).

    Converts video to prores_ks and audio to pcm_s16le using ffmpeg.

    Outputs .mov files into a changed/ folder.

## 📂 Output Format

    Video Codec: prores_ks (Profile 3, yuv422p10le)

    Audio Codec: pcm_s16le

    Container: .mov

    Frame Rate: 60 fps

    Resolution: 1920x1080 or 1080x1920 (depending on input)

## 🧾 Example Output

--------------------------
Successfully Converted: changed/myvideo.mov
--------------------------

📄 License

This project is licensed under the MIT License. Feel free to use, modify, and distribute it as needed.
🙏 Acknowledgements

    FFmpeg — the powerful multimedia framework used for conversions.
