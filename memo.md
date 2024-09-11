# mp4 to gif:

```
ffmpeg -i filename.mp4 -vf "fps=10,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" filename.gif
```