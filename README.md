# MyFlow

<img src="https://github.com/cyj893/MyFlow/blob/main/gitImgs/v.1.5.5_2.png?raw=true" width="500px" title="v.1.5.5_2"></img>

<br>

## Outline

### Features

> **Music as My Flow**

- Turn PDF sheet music through your flow, not page by page
- Freely customize the moving method
  - Put your face close to the camera to move to the next point
- Annotation feature is currently being developed.

### Environment
- Now Editing...

### Develop Period
2022/05/13 ~

### Library Dependencies
Snapkit
Then

## Contents
### Add, Move Point and Undo/Redo

<p align="center">
<img src="https://github.com/cyj893/MyFlow/blob/develop/gitImgs/v.0.5_1.gif?raw=true" width="300px" title="v.0.5_1"></img>
</p>

- Add the point
  1. Press the `+` button.
  2. Touch where you want to add a point.
- Move point
  1. Press the `hand` button.
  2. Select point to move by touching point number.
  3. Press and hold it, draw one horizontal stroke, then scroll up and down.
- Undo/Redo
  1. Press `undo/redo` button when you want it.
- Move to Point
  1. Press `<|` or `|>` button to move to previous/next point.

---

### Delete Selected Point

<p align="center">
<img src="https://github.com/cyj893/MyFlow/blob/main/gitImgs/v.1.5.5_1.gif?raw=true" width="300px" title="v.1.5.5_1"></img>
</p>

- Delete the point
  1. Press the `hand` button.
  2. Touch the point you want to delete.
  3. Press the `delete` button.

---

### Open and Control Multiple Files

<p align="center">
<img src="https://github.com/cyj893/MyFlow/blob/main/gitImgs/v.1.5.5_2.png?raw=true" width="300px" title="v.1.5.5_2"></img>
</p>

- State is saved
  - The tabs viewed, location, and scaleFactor are restored even if the user turns the app off and on.

---

### Play Mode

<p align="center">
<img src="https://github.com/cyj893/MyFlow/blob/develop/gitImgs/v.0.5_2.gif?raw=true" width="300px" title="v.0.5_2"></img>
</p>

- Add points at top of the selected pages
  1. Press `add multiple` button.
  2. Choose pages you want to add points on the top.
  3. Add points.
- Play mode
  1. Press the green `▶️` button.
  3. Play mode starts.
  4. You can go to next point by touching right side of the screen and previous point by touching left side of the screen.
  5. Press `⏹️` button to end play mode.

---

### Move to Point with TrueDepth Camera

- Now editing...

---

### Settings

- Now editing...

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
