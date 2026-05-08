# Game Concept — 彩色泡泡匹配 / Color Bubble Match

## Overview
A simple, colorful bubble-popping game designed for 5-year-old girls. Players match bubbles of the same color by clicking them, with cheerful sounds and friendly animal characters providing encouragement. The game runs in web browsers and features short, engaging sessions perfect for young attention spans.

## Player Fantasy
" I am a playful helper making colorful bubbles happy by matching them with my friends!"

## Detailed Rules

1. **Basic Gameplay**
   - Bubbles appear in a grid pattern
   - Each bubble has a color from a predefined set
   - Player clicks/taps on a bubble to select it
   - Selected bubble shows a highlight effect
   - Clicking an adjacent bubble of the same color creates a match

2. **Matching System**
   - 3 or more connected bubbles of the same color can be matched
   - Bubbles must be adjacent horizontally or vertically (not diagonally)
   - When matched, bubbles disappear with a pop animation
   - New bubbles fall from the top to fill empty spaces
   - Chain reactions occur when new matches form after bubbles fall

3. **Scoring**
   - Each matched bubble gives 10 points
   - Chain reaction bonuses multiply score
   - Bonus points for matching 4+ bubbles in a single group

4. **Timer System**
   - Each round lasts 90 seconds
   - Timer counts down visibly
   - Game ends when timer reaches zero
   - Player can start a new round

5. **Progression**
   - Start with 3 colors (pink, blue, yellow)
   - Every 3 rounds, add a new color (green, purple, orange)
   - Maximum of 6 colors

## Formulas

### Score Calculation
```
Base Score = Number of matched bubbles × 10
Chain Multiplier = 1 + (Number of chain reactions × 0.5)
Final Score = Base Score × Chain Multiplier

Example: Match 4 bubbles with 1 chain reaction
Final Score = (4 × 10) × (1 + 1 × 0.5) = 40 × 1.5 = 60 points
```

### Color Progression
```
Colors Available = 3 + floor(Round Number / 3)
Maximum Colors = 6

Round 1-3: 3 colors (Pink, Blue, Yellow)
Round 4-6: 4 colors (Green added)
Round 7-9: 5 colors (Purple added)
Round 10+: 6 colors (Orange added)
```

## Edge Cases

1. **Single Bubble Click**: Clicking a bubble with no same-color adjacent bubbles shows a "try again" animation but doesn't score
2. **Partial Matches**: If clicking creates a group of 2 bubbles, they don't disappear but show a "not enough" shake
3. **Empty Column**: When a column is emptied, all bubbles to the right shift left
4. **Board Refill**: If new bubbles create matches immediately, they pop automatically without player input
5. **Timer Expire**: At exactly zero, current match completes but no new matches allowed

## Dependencies

1. **Grid System**: Provides the bubble layout and position management
2. **Input System**: Handles mouse clicks and touch input
3. **Animation System**: Manages pop animations and bubble movements
4. **Audio System**: Plays pop sounds and background music
5. **UI System**: Displays score, timer, and game screens

## Tuning Knobs

| Knob | Range | Default | Effect |
|------|-------|---------|---------|
| `BaseBubbleScore` | 5-20 | 10 | Points per matched bubble |
| `ChainBonus` | 0.1-1.0 | 0.5 | Multiplier per chain reaction |
| `RoundDuration` | 60-180 | 90 | Seconds per round |
| `MinMatchSize` | 2-5 | 3 | Minimum bubbles to match |
| `NewColorInterval` | 2-5 | 3 | Rounds between new colors |
| `BubbleGridSize` | 6-12 | 8 | Grid width and height |

## Acceptance Criteria

1. **Core Functionality**
   - [ ] Bubble grid displays correctly with random colors
   - [ ] Clicking a bubble highlights it
   - [ ] Clicking adjacent same-color bubble creates match
   - [ ] 3+ bubbles disappear with animation
   - [ ] New bubbles fall from top

2. **Scoring System**
   - [ ] Score updates correctly after matches
   - [ ] Chain reactions trigger bonus points
   - [ ] Final score displays at round end

3. **Timer System**
   - [ ] 90-second timer counts down
   - [ ] Game ends at zero
   - [ ] Can start new round after game over

4. **Progression**
   - [ ] Colors increase every 3 rounds
   - [ ] Maximum of 6 colors
   - [ ] New color indication before appearing

5. **User Experience**
   - [ ] No error messages for young players
   - [ ] All interactions provide positive feedback
   - [ ] Simple menu to start/restart
   - [ ] Large, easy-to-click targets