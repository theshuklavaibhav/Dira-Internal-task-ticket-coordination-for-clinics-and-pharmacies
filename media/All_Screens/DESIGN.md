---
name: Indigo Health Modern
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#464555'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#777587'
  outline-variant: '#c7c4d8'
  surface-tint: '#4d44e3'
  primary: '#3525cd'
  on-primary: '#ffffff'
  primary-container: '#4f46e5'
  on-primary-container: '#dad7ff'
  inverse-primary: '#c3c0ff'
  secondary: '#a93349'
  on-secondary: '#ffffff'
  secondary-container: '#fe7488'
  on-secondary-container: '#730425'
  tertiary: '#3130c0'
  on-tertiary: '#ffffff'
  tertiary-container: '#4b4dd8'
  on-tertiary-container: '#d9d8ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e2dfff'
  primary-fixed-dim: '#c3c0ff'
  on-primary-fixed: '#0f0069'
  on-primary-fixed-variant: '#3323cc'
  secondary-fixed: '#ffdadc'
  secondary-fixed-dim: '#ffb2b9'
  on-secondary-fixed: '#400010'
  on-secondary-fixed-variant: '#891933'
  tertiary-fixed: '#e1e0ff'
  tertiary-fixed-dim: '#c0c1ff'
  on-tertiary-fixed: '#07006c'
  on-tertiary-fixed-variant: '#2f2ebe'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  headline-xl:
    fontFamily: Manrope
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-xl-mobile:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 30px
    fontWeight: '600'
    lineHeight: 38px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-max-width: 1440px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 40px
  stack-sm: 4px
  stack-md: 12px
  stack-lg: 24px
---

## Brand & Style

The design system is engineered for a high-performance healthcare environment that demands precision, reliability, and technical sophistication. It bridges the gap between clinical authority and modern SaaS efficiency. 

The aesthetic is a hybrid of **Minimalism** and **Glassmorphism**, emphasizing clarity through expansive white space and subtle depth. It evokes a sense of "Airy Professionalism"—an interface that feels lightweight yet structurally sound. The emotional response is one of calm confidence, ensuring that complex medical data remains legible and stress-free for the user.

## Colors

The palette is centered on **Deep Indigo**, a color that conveys intelligence and stability. This is balanced by **Soft Rose**, used sparingly as a high-intent accent for primary actions, critical notifications, and "human-centric" highlights.

- **Primary (Deep Indigo):** Used for navigation, primary branding, and structural UI elements.
- **Secondary (Soft Rose):** Reserved for call-to-actions (CTAs) and success-related feedback to provide a warm, approachable contrast.
- **Surface Strategy:** In light mode, surfaces use ultra-light grays (#F8FAFC) to maintain an airy feel. In dark mode, surfaces transition to a deep navy-tinted charcoal (#0F172A) to reduce eye strain while maintaining the Indigo DNA.

## Typography

This design system utilizes **Manrope** across all roles to maintain a cohesive, modern-tech identity. The typeface’s balanced geometric qualities provide excellent legibility for both quantitative medical data and long-form clinical notes.

Hierarchies are established through tight letter-spacing in headlines and generous line-height in body text to enhance the "airy" feel. Label styles utilize a slight tracking increase to ensure clarity at small sizes, particularly within dense dashboards.

## Layout & Spacing

The layout philosophy follows a **Fluid Grid** model with high-margin padding to reinforce the airy aesthetic. 

- **Desktop:** 12-column grid with 24px gutters. Content is centered within a 1440px max-width container to prevent line lengths from becoming unreadable on ultra-wide monitors.
- **Tablet:** 8-column grid with 20px gutters and 24px side margins.
- **Mobile:** 4-column grid with 16px gutters and 16px side margins.

Vertical rhythm is strictly maintained using an 8px baseline. Components utilize "Stack" variables to ensure consistent white space between grouped elements.

## Elevation & Depth

To achieve a "Modern Tech" feel, this design system moves away from heavy shadows in favor of **Tonal Layers** and **Glassmorphism**.

- **Surface Tiers:** Backgrounds are at the lowest tier. Containers (cards) sit on top with a subtle 1px border (#E2E8F0) and a very soft, diffused ambient shadow (8% opacity Indigo tint).
- **Overlays:** Modals and dropdowns use a "Backdrop Blur" effect (12px) with a semi-transparent white or dark-navy fill (85% opacity).
- **Interactivity:** On hover, elements slightly lift using a secondary, sharper shadow to provide tactile feedback without cluttering the visual field.

## Shapes

The shape language is consistently **Rounded**. This softens the technical nature of the healthcare data, making the application feel more accessible and user-friendly.

- **Standard Elements:** 0.5rem (8px) for buttons, input fields, and small cards.
- **Large Containers:** 1rem (16px) for main dashboard sections and modals.
- **Interactive Pills:** 1.5rem (24px) for status badges and search bars.

## Components

### Buttons
- **Primary:** Filled Deep Indigo with white text. High-contrast, bold, and authoritative.
- **Action (CTA):** Filled Soft Rose with white text. Used for "Book Appointment" or "Critical Update."
- **Ghost:** Transparent background with Indigo border; for secondary actions.

### Cards
Cards are the primary container for information. They feature a white background (light mode), 8px border-radius, and a subtle 1px border. No heavy shadows—depth is created by the contrast against the light-gray page background.

### Input Fields
Inputs use a "floating label" style with a 1px border that thickens and changes to Deep Indigo on focus. Errors are highlighted using a saturated Red-Orange, distinct from the Soft Rose accent.

### Chips & Badges
Badges use low-saturation background tints of the primary colors (e.g., a 10% opacity Soft Rose background with 100% opacity Soft Rose text) to maintain a soft, modern look.

### Lists
Medical records and patient lists use generous vertical padding (16px) and thin dividers (#F1F5F9) to ensure that dense information remains digestible and airy.