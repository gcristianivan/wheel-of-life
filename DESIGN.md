# Design System for Wheel of Life

This document outlines the design system for the **Wheel of Life** application. It serves as a reference for all UI/UX decisions, ensuring consistency across the application.

## 1. Core Principles

-   **Theme:** Dark Mode by default.
-   **Aesthetic:** Modern, Glassmorphism, Vibrant Accents.
-   **Philosophy:** Visualizing balance through color and shape.
-   **Typography:** Clean, geometric sans-serif for readability.

## 2. Color Palette

### 2.1. Backgrounds
The application uses a deep, rich gradient to create depth.

| Name               | Hex Code    | Description |
| ------------------ | ----------- | ----------- |
| **Deep Navy**      | `#2E335A`   | Primary background gradient start. |
| **Dark Void**      | `#1C1B33`   | Primary background gradient end. |
| **Solid Dark**     | `#202028`   | Fallback solid background color. |

**Usage:**
-   **Main Background:** Linear Gradient from `#2E335A` to `#1C1B33`. Directions may vary (TopLeft -> BottomRight most common).

### 2.2. Accent Colors (Primary)
Used for primary actions, highlights, and key UI elements.

| Name               | Hex Code    | Description |
| ------------------ | ----------- | ----------- |
| **Primary Accent** | `#6C63FF`   | Main brand color, used for buttons and key highlights. |

### 2.3. Category Colors (The Wheel)
Each life pillar has a distinct, vibrant color for quick identification.

| Category        | Hex Code    | Color Name      |
| --------------- | ----------- | --------------- |
| **Health**      | `#69F0AE`   | Mint Green      |
| **Career**      | `#40C4FF`   | Light Blue      |
| **Finances**    | `#7C4DFF`   | Deep Purple     |
| **Growth**      | `#FF4081`   | Hot Pink        |
| **Romance**     | `#FF5252`   | Red             |
| **Social**      | `#FFAB40`   | Orange          |
| **Fun**         | `#FFD740`   | Amber/Yellow    |
| **Environment** | `#18FFFF`   | Cyan            |

### 2.4. Semantic Colors
| Name       | Hex Code                | Usage |
| ---------- | ----------------------- | ----- |
| **Success**| `#66BB6A` (with opacity)| Positive actions (Yes button). |
| **Error**  | `#EF5350` (with opacity)| Destructive actions (No button). |
| **Text**   | `#FFFFFF` (White)       | Primary text color. |
| **Muted**  | `#B3B3B3` (White70)     | Secondary text, subtitles. |

## 3. Typography

**Font Family:** `Outfit` (Google Fonts)

| Style Name       | Size | Weight | Line Height | Usage |
| ---------------- | ---- | ------ | ----------- | ----- |
| **Heading 1**    | 32px | Bold (700) | 1.2         | Main Page Titles, Hero Text. |
| **Heading 2**    | 24px | SemiBold (600) | 1.3         | Section Headers, Card Titles. |
| **Body Text**    | 16px | Regular (400) | 1.5         | Standard paragraph text, long descriptions. |
| **Small Text**   | 14px | Regular (400) | 1.4         | Labels, captions, secondary info. |
| **Tiny/Badge**   | 12px | Medium (500) | 1.2         | Metadata, chart labels. |

## 4. Components & Styling

### 4.1. Glassmorphism Cards
The core container style for content on top of the dark gradient.
-   **Background:** `Color(0x1FFFFFFF)` (White with ~12% opacity).
-   **Border:** 1px solid `White (10% opacity)`.
-   **Border Radius:** `20px`.
-   **Shadow:** `BoxShadow(color: Black (10% opacity), blur: 16px, spread: 4px)`.
-   **Blur Effect:** `BackdropFilter` with `sigmaX: 10`, `sigmaY: 10`.

### 4.2. Buttons
**Primary Action Button:**
-   **Background:** Primary Accent (`#6C63FF`).
-   **Text Color:** White.
-   **Border Radius:** `12px` or `16px`.
-   **Height:** `50px` - `56px`.
-   **Typography:** Bold, 16px or 18px.
-   **Elevation:** Slight shadow for depth.

**Option Buttons (Assessment):**
-   **Shape:** Pill/Capsule (`BorderRadius.circular(30)`).
-   **Height:** `56px`.
-   **Border:** Thin white border (`Colors.white24`).
-   **Shadow:** Colored glow based on Semantic Color.

### 4.3. Inputs
-   **Style:** Underline Input by default.
-   **Text Color:** White.
-   **Hint Color:** White54.
-   **Focus Color:** Primary Accent (`#6C63FF`).

### 4.4. Charts (The Wheel)
-   **Type:** Polar Area / Pie Chart hybrid.
-   **Logic:** Radius scales with score.
-   **Opacity:** Slices use `0.8` opacity to blend slightly with the dark background.
-   **Touch Interaction:** Tapping a slice navigates to the detail view for that category.

## 5. Iconography
-   **Style:** Filled or Outlined Material Icons.
-   **Color:** Primarily White.
-   **Size:** Standard 24px.

## 6. Layout Guidelines
-   **Padding:** Standard padding is `24px` horizontal for main content areas.
-   **Spacing:**
    -   Small gap: `8px`
    -   Medium gap: `16px` - `20px`
    -   Large gap: `32px` - `40px`
-   **Safe Area:** All screens respect device safe areas (notches, home indicators).

