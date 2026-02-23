# ⚡ Flashbang Overlay for Twitch Streams

Turn your Twitch chat into a chaotic battlefield.

**Flashbang Overlay** is a Windows desktop application that runs as a real-time in-game overlay, allowing viewers to interact directly with the stream. With a channel points action, viewers can throw a virtual **flashbang** at the streamer — briefly blinding the screen with a cinematic effect inspired by classic tactical shooters like Counter-Strike.

---

## 🎮 What It Does

The application launches as a lightweight overlay above your game window and listens to Twitch events in real time. When triggered by viewers, it plays a flashbang animation, temporarily “blinding” the streamer and creating intense, funny, and unpredictable moments during gameplay.

Perfect for:

* Interactive Twitch streams
* Competitive FPS gameplay
* Community-driven chaos

---

## 🖼 Example

Below is an example of how the flashbang effect looks during gameplay:

![Flashbang Example](images/example.gif)

---

## 🚀 How It Works

1. Run the application on Windows.
2. Connect your Twitch account.
3. Configure the trigger (channel points reward).
4. Launch your game — the overlay will appear automatically.
5. Let your viewers cause chaos.

---

## ⚙️ Configuration

You can customize the reward button name directly in the `config.json` file:

```json
{
  "flashbang": "Flashbang"
}
```

Change the value of `flashbang` to match the Twitch Channel Points action you want viewers to trigger. This allows you to fully localize or rename the flashbang interaction without rebuilding the application.

---

## 💡 Use Cases

* Add stakes to clutch moments
* Reward viewers with real influence over gameplay
* Create hilarious "panic" situations on stream

---

## ⚠️ Disclaimer

This project is intended for entertainment purposes. Use responsibly — your viewers *will* abuse it.

---

## ❤️ Contributing

Pull requests, ideas, and feedback are welcome. If you build cool integrations or new effects — share them!

---

Enjoy the flash… and try not to get blinded. 💥
