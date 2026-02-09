# Multify

Multify is a macOS native developer productivity tool that captures context at the moment of thought. It helps developers preserve intent, reduce context switching, and return to complex work without losing momentum.

## The Problem

Developers constantly lose context.

Screenshots are taken without explanation. Notes are written without structure. Bugs are remembered vaguely. When you return later, the original intent is gone.

Most tools capture artifacts. Very few capture intent.

## The Solution

Multify captures screenshots, audio, transcripts, and notes in a lightweight workflow designed for developers. It turns fleeting thoughts into structured context that can be reused, shared, or acted upon later.

For the Gemini 3 Hackathon, Multify introduces intent-aware AI modes that transform captured context into meaningful next steps.

## AI Powered Modes

Multify integrates Gemini 3 through a single, focused AI surface exposed via a sparkle icon in the toolbar. This allows developers to apply AI intentionally, not passively.

Ask Mode

Helps developers understand context, explore ideas, and reason about tradeoffs. Optimized for clarity and explanation.

Debug Mode

Analyzes captured context to identify likely causes, edge cases, and debugging strategies. Optimized for step by step reasoning.

Build Mode

Turns intent into action by generating concrete steps and example implementations. Optimized for execution.

Each mode assumes a different expert role while preserving the same underlying developer context.

## Why Gemini 3

Multify uses Gemini 3 for its reasoning ability, multimodal understanding, and low latency. Gemini processes screenshots and transcripts together, allowing it to infer intent rather than simply summarize text.

The AI is not a chat interface. It is a context engine that adapts to developer intent.

## Demo

A short demo video is available showing:

Capturing developer context

Switching between AI modes

Gemini producing different outputs from the same input

## Running Locally

Clone the repository

Open the project in Xcode

Add your Gemini API key as an environment variable

Build and run the macOS app

No accounts or logins required.

## Hackathon Submission

This project was built for the Gemini 3 Hackathon and represents a new application using Gemini 3 as a core capability.
