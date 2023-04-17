# MyFlow

<img src="https://github.com/cyj893/MyFlow/blob/main/gitImgs/readmeTitle.png?raw=true" width="500px" title="readmeTitle"></img>

> #### Music as My Flow

<br>

## Outline

### Features

- Turn PDF sheet music through your flow, not page by page
- Freely customize the moving method
  - Put your face close to the camera to move to the next point
- Annotation feature is currently being developed.

### Environment
- Xcode (14.0.1)
- Swift (5.7)
- Minimum Deployments: iOS 15.0

### Develop Period
2022/05/13 ~

### Library Dependencies
- SnapKit (5.0.1)
- Then (2.7.0)

## Contents
### Add, Move, Delete Point and Undo/Redo

<p align="center">
<img src="https://github.com/cyj893/MyFlow/blob/develop/gitImgs/pointHandling.gif?raw=true" width="300px" title="pointHandling"></img>
</p>

- Add the point
  1. Press the `+` button.
  2. Touch where you want to add a point.
  - Or, Add points at top of the selected pages
    1. Press `add multiple` button(next to `hand` button).
    2. Choose pages you want to add points on the top.
    3. Add points.
- Move point
  1. Press the `hand` button.
  2. Select point to move by touching point number.
  3. Press and hold it, draw one horizontal stroke, then scroll up and down.
- Delete the point
  1. Press the `hand` button.
  2. Touch the point you want to delete.
  3. Press the `delete` button.
- Undo/Redo
  1. Press `undo/redo` button when you want it.
- Move to Point
  1. Press `<|` or `|>` button to move to previous/next point.

---

### Open and Control Multiple Files

<p align="center">
<img src="https://github.com/cyj893/MyFlow/blob/main/gitImgs/v.1.5.5_2.png?raw=true" width="300px" title="v.1.5.5_2"></img>
</p>

- State is saved
  - The tabs viewed, location, and scaleFactor are restored even if the user turns the app off and on.
  - The point information added to each file is saved and maintained even if the user turns the file off and on.

---

### Play Mode

<p align="center">
<img src="https://github.com/cyj893/MyFlow/blob/develop/gitImgs/playMode.gif?raw=true" width="300px" title="playMode"></img>
</p>

- Play mode
  1. Press the green `▶️` button.
  3. Play mode starts.
  4. You can go to next point by touching right side of the screen and previous point by touching left side of the screen.
    - You can change the orientation and width of the tab area in [settings](#Set-Area).
  5. Press `⏹️` button to end play mode.

---

### Move to Point with TrueDepth Camera

- Now editing...

---

### Settings

#### Set Style to Move

<p align="center">
<img src="https://github.com/cyj893/MyFlow/blob/develop/gitImgs/setting_move.gif?raw=true" width="300px" title="setting_move"></img>
</p>

- You can choose whether to move by scrolling or directly without animation when you move to the next point.

#### Set Area

<p align="center">
<img src="https://github.com/cyj893/MyFlow/blob/develop/gitImgs/setting_area.gif?raw=true" width="300px" title="setting_area"></img>
</p>

- You can customize the width of the tap area for moving to the previous or next point as much as you like.
- You can change the orientation as well.

#### Set Distance

<p align="center">
<img src="https://github.com/cyj893/MyFlow/blob/develop/gitImgs/setting_distance.gif?raw=true" width="300px" title="setting_distance"></img>
</p>

- You can set the sensitivity when moving with the TrueDepth camera.

---

### In terms of Development
- MVVM architecture
- Design patterns
  - Command pattern
  - State pattern
  - Strategy pattern
- UI for debugging

---

## License
MyFlow is released under the [MIT License](http://www.opensource.org/licenses/mit-license).
