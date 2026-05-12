# Parallax Interior Mapping Demo

A small demo that uses Three.js and a fragment shader to simulate interior parallax / interior mapping for an equirectangular room texture.

Files:
- `index.html` - single-file demo (contains shaders, UI and logic)
- `roomtest5.exr` - example EXR equirectangular room texture (default)
- `shaders/` - (optional) shader files if you want them external

How to run:
1. Serve the folder over HTTP. You can use VSCode Live Server or Python's http.server:

```powershell
# from the project folder
python -m http.server 5500
```

2. Open `http://localhost:5500/index.html` in a modern browser (Chrome recommended).

Usage:
- Use the mouse to orbit the view (left-drag) and scroll to zoom.
- Use the controls on the left to tweak `Depth Scale`, `Flip`, `Rotation` and `Plane Tilt`.
- Upload a new texture (EXR, JPG, PNG) using the file input. A small preview is shown beneath the upload control.
