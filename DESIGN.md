# DESIGN.md - Universal Appcast Studio

## Brand & Product Identity
Universal Appcast Studio is a precision developer tool for authoring, validating, and inspecting Appcast XML feeds (Sparkle 2, WinSparkle/NetSparkle, and Flutter Upgrader).
The interface is designed as an IDE-grade workspace: tactile, dense, high-contrast, and focused on data integrity.

## Liveliness Dials
- **ENERGY**: 1 (Calm, focused, zero marketing fluff)
- **RHYTHM**: 2 (Structured grid with distinct editor and inspector zones)
- **MOTION**: 1 (Subtle, purposeful state transitions and hover responses only)

Reading this as: Developer workstation for multi-platform software creators, in an engineering/monospace craft style, dial ENERGY 1 / RHYTHM 2 / MOTION 1.

## Color System (WCAG AA Compliant)

### Light Theme
- **Canvas / Background**: `#F8FAFC` (Slate 50)
- **Surface / Card**: `#FFFFFF` (Crisp white)
- **Surface Inset / Input**: `#F1F5F9` (Slate 100)
- **Border Default**: `#CBD5E1` (Slate 300)
- **Border Strong / Active**: `#94A3B8` (Slate 400)
- **Text Primary**: `#0F172A` (Slate 900, 15:1 contrast)
- **Text Secondary**: `#475569` (Slate 600, 7.2:1 contrast)
- **Text Muted**: `#64748B` (Slate 500, 4.6:1 contrast)
- **Brand Accent**: `#B45309` (Amber 700 - accessible on light, 5.2:1 contrast)
- **Accent Subtle**: `#FEF3C7` (Amber 100)

### Dark Theme
- **Canvas / Background**: `#0B0F17` (Deep Obsidian)
- **Surface / Card**: `#141C2B` (Layer 1 elevation)
- **Surface Inset / Input**: `#1B2538` (Layer 2 elevation)
- **Border Default**: `#28354D` (Crisp contrast border)
- **Border Strong / Active**: `#475569` (Slate 600)
- **Text Primary**: `#F8FAFC` (Slate 50, 16:1 contrast)
- **Text Secondary**: `#94A3B8` (Slate 400, 7:1 contrast)
- **Text Muted**: `#64748B` (Slate 500, 4.5:1 contrast)
- **Brand Accent**: `#F59E0B` (Amber 500 - vibrant, readable on dark)
- **Accent Subtle**: `#78350F` (Amber 900 / 30% alpha)

### Semantics
- **Success**: `#10B981` (Dark) / `#047857` (Light)
- **Warning**: `#F59E0B` (Dark) / `#B45309` (Light)
- **Danger**: `#EF4444` (Dark) / `#B91C1C` (Light)
- **Info**: `#38BDF8` (Dark) / `#0369A1` (Light)

## Anti-Slop Discipline
1. **No generic blue/emerald gradient templates**: Palette anchored in Deep Obsidian and warm Bronze/Amber.
2. **No pill-shaped cards or excessive rounded buttons**: Elements use strict 6px to 8px radii.
3. **No meaningless badges**: Badges only represent actionable states (e.g., target OS, architecture, security flag).
4. **No fake or dead UI**: Every button, input, toggle, tab, and download action is wired to actual state.
5. **Full Theme Resilience**: Both Dark Mode and Light Mode are first-class, tested, and switchable via toggle.
6. **Keyboard Operable**: Tab stops, Esc to dismiss modal, Enter to submit.
