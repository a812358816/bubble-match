# Game Concept: Hoop Master

*Created: 2026-05-07*
*Status: Draft*

---

## Elevator Pitch

> It's an endless basketball shooting game where you perform satisfying trick shots and power-ups to build the ultimate basketball arena, all while competing for high scores and unlocking new equipment.

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | Hyper-casual sports arcade with progression elements |
| **Platform** | Mobile-first with cross-platform play (iOS, Android, PC) |
| **Target Audience** | Casual gamers, sports fans, idle game enthusiasts (18-45) |
| **Player Count** | Single-player with leaderboards |
| **Session Length** | 3-15 minutes (bite-sized sessions) |
| **Monetization** | Free-to-play with cosmetic upgrades and ad-based monetization |
| **Estimated Scope** | Small (2-4 months) for MVP |
| **Comparable Titles** | FRVR Basketball, Basketball FRVR, Basketball Stars |

---

## Core Fantasy

You become a basketball superstar mastering impossible shots and building your dream arena. The satisfaction of landing perfect swishes, the thrill of chain combos, and the pride of unlocking new gear creates an empowering loop that makes you feel like a basketball legend regardless of your real-life skills.

---

## Unique Hook

It's like FRVR Basketball AND ALSO a deep progression system where your shooting skills directly unlock better equipment and arena upgrades. The combination of pure shooting satisfaction with meaningful progression creates an "one more shot" addiction loop that keeps players coming back.

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics (What the player FEELS)

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Sensation** (sensory pleasure) | 1 | Perfect swish sound, satisfying ball physics, particle effects on successful shots |
| **Fantasy** (make-believe, role-playing) | 2 | Become a basketball pro, arena tycoon identity |
| **Challenge** (obstacle course, mastery) | 1 | Increasing difficulty, trick shot challenges, precision requirements |
| **Discovery** (exploration, secrets) | 2 | Hidden ball types, secret arenas, special shot patterns |
| **Expression** (self-expression, creativity) | 1 | Customization options for ball, hoop, arena |
| **Narrative** | N/A | Not focus - pure arcade experience |
| **Fellowship** | N/A | Leaderboards, but no direct social interaction |
| **Submission** | 3 | Relaxing shooting mechanics, idle progression |

### Key Dynamics (Emergent player behaviors)

- Players will experiment with different shot angles and power to master trick shots
- Players will chain shots together for combo multipliers and high scores
- Players will deliberately fail certain shots to position for better bonus shots
- Players will revisit early levels with upgraded equipment to beat high scores

### Core Mechanics (Systems we build)

1. **Physics-based shooting** - Realistic ball trajectory with swipe controls for angle and power
2. **Progressive difficulty** - Moving hoops, changing distances, obstacles, wind effects
3. **Power-up and equipment system** - Special balls, hoop effects, arena bonuses
4. **Combo chaining** - Consecutive successful shots multiply score
5. **Arena building** - Permanent upgrades to court appearance and equipment

---

## Player Motivation Profile

### Primary Psychological Needs Served

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Competence** (mastery, skill growth) | Mastering different shot techniques, beating personal bests | Core |
| **Autonomy** (freedom, meaningful choice) | Choosing equipment, shot strategy when to risk | Supporting |
| **Relatedness** (connection, belonging) | Global leaderboards, friends comparisons | Minimal |

### Player Type Appeal (Bartle Taxonomy)

- [X] **Achievers** (goal completion, collection, progression) — How: Unlocking all equipment, topping leaderboards, completing challenges
- [ ] **Explorers** (discovery, understanding systems, finding secrets) — How: Discovering hidden trick shot patterns, secret arenas
- [ ] **Socializers** (relationships, cooperation, community) — How: Minimal, leaderboards only
- [X] **Killers/Competitors** (domination, PvP, leaderboards) — How: Climbing global rankings, beating friends' scores

### Flow State Design

- **Onboarding curve**: First 3 shots teach basic swipe controls, then introduces combo system
- **Difficulty scaling**: Gradual introduction of moving hoops, then obstacles, then special challenges
- **Feedback clarity**: Visual and audio feedback on every shot, clear combo counter
- **Recovery from failure**: No penalty - next shot immediately available

---

## Core Loop

### Moment-to-Moment (30 seconds)
Swipe to shoot basketball at hoop. Perfect swishes trigger satisfying sound effects. Ball physics creates realistic bounces for near misses.

### Short-Term (5-15 minutes)
Chain consecutive shots for combo multipliers. Collect coins from successful shots. Choose between saving coins for upgrades or using power-ups. Attempt bonus challenges for extra rewards.

### Session-Level (30-120 minutes)
Progress through increasingly challenging levels. Unlock new ball types and arena features. Build your dream basketball court. Climb daily and all-time leaderboards.

### Long-Term Progression
Unlock entire equipment collections: legendary balls, special hoop effects, themed courts. Master all shot types and trick shots. Become a top 100 global player.

### Retention Hooks
- **Curiosity**: What new equipment unlocks at level 25? What's the secret ball?
- **Investment**: Upgraded arena represents player's progression journey
- **Mastery**: Perfecting trick shot techniques
- **Social**: Comparing scores with friends on leaderboards

---

## Game Pillars

### Pillar 1: Satisfying Shooting
*Design test*: If debating between realistic physics vs. more forgiving controls, choose satisfying physics every time. Shots should feel good even when missed.

### Pillar 2: Meaningful Progression
*Design test*: When adding new features, ask "Does this give players a reason to keep playing beyond the core shooting?"

### Pillar 3: Accessible Mastery
*Design test*: If a feature feels too hard, either simplify the tutorial or make the basic version accessible while keeping advanced techniques for experts.

### Anti-Pillars (What This Game Is NOT)
- **NOT a realistic basketball simulator** - We prioritize fun over realism
- ** NOT a complex RPG** - No deep character stats or skill trees
- **NOT dependent on fast reflexes** - Strategy and timing over raw speed

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| FRVR Basketball | Simple one-touch controls, endless gameplay | Deeper equipment progression, arena building | Validates casual sports game appeal |
| Basketball Stars | Quick PvP matches, skill-based gameplay | Single-player focus with progression | Shows market demand for basketball games |
| Idle Heroes/Games | Character progression, equipment collection | Applied to sports genre instead of RPG | Proven progression loop works |

**Non-game inspirations**: Basketball highlight reels (emphasizing spectacular shots), sports arena atmospheres, arcade game high score traditions

---

## Target Player Profile

| Attribute | Detail |
| ---- | ---- |
| **Age range** | 18-45 |
| **Gaming experience** | Casual to mid-core, enjoys quick mobile games |
| **Time availability** | Short bursts (3-10 minutes) during commutes, breaks |
| **Platform preference** | Mobile first, will play on PC if convenient |
| **Current games they play** | FRVR, Subway Surfers, Candy Crush, basketball games |
| **What they're looking for** | Satisfying gameplay, clear progression, casual competition |
| **What would turn them away** | Too demanding time commitment, pay-to-win mechanics, frustrating controls |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | Unity - strong 2D physics, mobile optimization, extensive asset store |
| **Key Technical Challenges** | Smooth ball physics across devices, satisfying visual/audio feedback, progression data persistence |
| **Art Style** | Clean, vibrant cartoon style with exaggerated physics |
| **Art Pipeline Complexity** | Medium - custom assets needed but stylized approach simplifies it |
| **Audio Needs** | Critical - satisfying shot sounds, crowd reactions, upgrade SFX |
| **Networking** | Leaderboards only (using Unity services or Firebase) |
| **Content Volume** | Minimal focus - procedurally generated challenges, 50+ equipment items |
| **Procedural Systems** | Level generation for endless gameplay, difficulty scaling algorithms |

---

## Risks and Open Questions

### Design Risks
- Risk 1 - Core shooting mechanics may not sustain interest long-term
- Risk 2 - Progression system may feel too grindy without proper pacing

### Technical Risks
- Risk 1 - Physics may behave differently across devices and resolutions
- Risk 2 - Save system and progression persistence must be bulletproof

### Market Risks
- Risk 1 - Sports genre is competitive with established titles
- Risk 2 - Casual games require constant content updates to maintain retention

### Scope Risks
- Risk 1 - Equipment system could expand uncontrollably
- Risk 2 - Visual polish requirements may exceed time budget

### Open Questions
- Question 1 - How to monetize without pay-to-win perception? (Prototype different models)
- Question 2 - What's the right balance between skill and luck? (Test different difficulty curves)

---

## MVP Definition

**Core hypothesis**: Players find the combination of satisfying physics-based shooting with equipment progression engaging for 10+ minute sessions.

**Required for MVP**:
1. Basic shooting mechanics with physics
2. Simple progression system (3 equipment tiers)
3. Combo scoring system
4. Basic arena visual upgrades
5. Leaderboard integration

**Explicitly NOT in MVP**:
- Complex trick shot challenges
- Social features (friends list)
- Multiple arenas
- Advanced ball physics modifiers

### Scope Tiers

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **MVP** | 10 ball types, 1 arena, 20 levels | Basic shooting, progression, leaderboards | 4 weeks |
| **Vertical Slice** | Full progression system, 5 arenas, trick shots | All core mechanics, complete loop | 8 weeks |
| **Alpha** | All planned equipment, all arenas challenges | Complete feature set | 12 weeks |
| **Full Vision** | Post-launch content, seasonal events, special tournaments | Live service features | Ongoing |

---

## Next Steps

- [ ] Get concept approval from creative-director
- [ ] Fill in CLAUDE.md technology stack based on engine choice (`/setup-engine`)
- [ ] Create game pillars document (`/design-review` to validate)
- [ ] Decompose concept into systems (`/map-systems` — maps dependencies, assigns priorities, guides per-system GDD writing)
- [ ] Create first architecture decision record (`/architecture-decision`)
- [ ] Prototype core loop (`/prototype [core-mechanic]`)
- [ ] Validate core loop with playtest (`/playtest-report`)
- [ ] Plan first milestone (`/sprint-plan new`)