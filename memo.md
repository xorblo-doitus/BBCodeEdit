# mp4 to gif:

```
ffmpeg -i color_completion.mp4 -vf "fps=10,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" color_completion_v2.gif
```