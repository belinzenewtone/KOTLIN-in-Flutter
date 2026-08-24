# Taste

- Prefers deploying and verifying builds on a physical Android device connected via adb (installs the APK and expects it launched/tested on the phone, not an emulator). Confidence: 0.6
- Communicates in very terse, fragment-style instructions (e.g., "phone connected install it", "explain this: ...") and expects the agent to act directly without restating the plan. Confidence: 0.6
- Wants technical caveats/limitations (e.g., un-wired features, release-signing details) explained clearly and grounded in the actual codebase when mentioned, not just listed as deltas. Confidence: 0.4
