# Portfolio Simulator

<p align="center">
  <img src="https://cdn-icons-png.flaticon.com/512/3314/3314336.png" width="100" />
</p>

## Overview
This is a Portfolio Simulator project. I built this to demonstrate how a modern, high-quality, and scalable Flutter application should look and feel. 

Instead of just throwing together a couple of screens, I treated this like a production-ready feature. My goal was to balance **clean architecture** with **delightful UX**. I wanted the app to feel alive, not static.

## Key Design Decisions (The "Why")

You might notice a few specific choices I made in the codebase. Here's why:

1.  **Simulated Network Delay (Shimmer Effects)**
    *   In the `StockService`, I added a deliberate 1-second delay.
    *   *Why?* To showcase the **Shimmer Loading** state. In a real app, API calls take time. I wanted to verify that the UI handles "loading" gracefully without jarring empty screens.

2.  **Backwards Data Generation**
    *   The charts look suspiciously consistent with the current price, right? That's by design.
    *   *Why?* Instead of generating random graph points and trying to match the end price, I generated the history **backwards** from the current live price. This ensures the graph's final point *always* mathematically matches the big number you see on screen. It creates a sense of trust in the data.

3.  **Aggregated "All-Time" Header Graph**
    *   The graph in the header isn't just a random squiggle.
    *   *Why?* I wrote logic in `PortfolioProvider` to aggregate the historical value of *every single stock* you hold. If one stock crashed 3 months ago, the header graph actually reflects that dip. It’s consistent.

4.  **Custom Scroll Behavior**
    *   You might be testing this on a web desktop browser.
    *   *Why?* Flutter Web doesn't support mouse-drag scrolling by default (it expects a touch screen or wheel). I added `CustomScrollBehavior` in `main.dart` so you can click-and-drag lists just like you would on a mobile device.

## Architecture

I used a features-based **Clean Architecture** approach. It might seem like overkill for 2 screens, but it's the only way to scale.

*   `core/`: Where the design system lives. `app_theme.dart` handles the Dark/Light mode toggle logic so we don't pollute UI widgets with color codes.
*   `data/`: Pure data. `Stock` models and the `StockService`. The UI doesn't know where data comes from (API or Mock), it just asks for it.
*   `providers/`: The "Brain". `PortfolioProvider` manages the state. It holds the logic for "Starring" a stock and calculating Total PnL.
*   `presentation/`: The "Face". Broken down into `screens` and `widgets`. I extracted `StockCard` and `PriceChart` because they were getting too big and needed strict isolation.

## Features Checklist

*   **Portfolio Overview**: Total Equity calculation, list of holdings, and a mini-sparkline for quick trends.
*   **Stock Detail**: Interactive chart (1D/1W/1M/1Y/All), dynamic PnL coloring (Red for loss, Green for profit based on *that* period), and AI insights.
*   **Theming**: Fully persistent Dark/Light mode.
*   **Performance**: Hero animations for zero-delay navigation.

## Setup

1.  **Get Packages**: `flutter pub get`
2.  **Run**: `flutter run -d chrome` (or your preferred device).
