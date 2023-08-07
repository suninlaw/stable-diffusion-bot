# Stable Diffusion Discord Bot

This is a Discord bot that interfaces with the Automatic1111 API, from this project: https://github.com/AUTOMATIC1111/stable-diffusion-webui 

This version is forked from https://github.com/AndBobsYourUncle/stable-diffusion-discord-bot, is optimized for SDXL, and includes scripts and instructions for using it in a Docker container.

Video showing off the current features:
https://www.youtube.com/watch?v=of5MBh3ueMk

## Building

1. Clone this repository
2. Install Go  * This varies with your operating system, but the easiest way is to use the official installer: https://golang.org/dl/ 
3. Build the bot with `go build`

## Usage 

1. Create a Discord bot and get the token
2. Add the Discord bot to your Discord server. It needs permissions to post messages, use slash commands, mentioning anyone, and uploading files.
3. Ensure that the Automatic 1111 webui is running with `--api` (and also `--listen` if it is running on a different computer than the bot).
4. Run the bot with `./stable_diffusion_bot -token <token> -guild <guild ID> -host <webui host, e.g. http://127.0.0.1:7860>`
   * It's important that the `-host` parameter matches the IP address where the A1111 is running. If the bot is on the same computer, `127.0.0.1` will work.
   * There needs to be no trailing slash after the port number (which is `7860` in this example). So, instead of `http://127.0.0.1:7860/`, it should be `http://127.0.0.1:7860`.
5. The first run will generate a new SQLite DB file in the current working directory.

## Building (Docker)

1. (Same as above) Clone this repository
2. (Same as above) Install Go  * This varies with your operating system, but the easiest way is to use the official installer: https://golang.org/dl/ 
3. Run build.sh - this will build a local Docker image called stable-diffusion-bot

## Usage (Docker)

1. (Same as above) Create a Discord bot and get the token
2. (Same as above) Add the Discord bot to your Discord server. It needs permissions to post messages, use slash commands, mentioning anyone, and uploading files.
3. (Same as above) Ensure that the Automatic 1111 webui is running with `--api` (and also `--listen` if it is running on a different computer than the bot).
4. Create an empty SQLite DB file

```bash
touch /path/to/sd_discord_bot.sqlite

```

5. Run the bot with the following docker command.

```bash
docker run -d \
  --name=stable-diffusion-bot \
  -v /path/to/sd_discord_bot.sqlite:/usr/src/bot/sd_discord_bot.sqlite:rw \
  -e TOKEN="insert the token here from step 1" \
  -e GUILD="insert the guild ID" \
  -e HOST="insert webui host, e.g. http://127.0.0.1:7860" \
  --restart unless-stopped \
  stable-diffusion-bot

```

## Building (Docker)

(Same as above) 1. Clone this repository
(Same as above) 2. Install Go  * This varies with your operating system, but the easiest way is to use the official installer: https://golang.org/dl/ 
3. Run build.sh - this will build a local Docker image called stable-diffusion-bot

## Usage (Docker)

(Same as above) 1. Create a Discord bot and get the token
(Same as above) 2. Add the Discord bot to your Discord server. It needs permissions to post messages, use slash commands, mentioning anyone, and uploading files.
(Same as above) 3. Ensure that the Automatic 1111 webui is running with `--api` (and also `--listen` if it is running on a different computer than the bot).
4. Create an empty database file

```bash
touch /path/to/sd_discord_bot.sqlite

```

5. Run the bot with the following docker command.

```bash
docker run -d \
  --name=stable-diffusion-bot \
  -v /path/to/sd_discord_bot.sqlite:/usr/src/bot/sd_discord_bot.sqlite:rw \
  -e TOKEN="insert the token here from step 1" \
  -e GUILD="insert the guild ID" \
  -e HOST="insert webui host, e.g. http://127.0.0.1:7860" \
  --restart unless-stopped \
  stable-diffusion-bot

```

6. The first run will generate a new SQLite DB file in the current working directory.

The `-imagine <new command name>` flag can be used to have the bot use a different command when running, so that it doesn't collide with a Midjourney bot running on the same Discord server.

## Commands

### `/imagine_settings`

Responds with a message that has buttons to allow updating of the default settings for the `/imagine` command.

By default, the size is 1024x1024, the recommended resolution for Stable Diffusion XL. However, if you are not running the Stable Diffusion XL model, you might want to change this to 768x768 or 512x512.

Choosing an option will cause the bot to update the setting, and edit the message in place, allowing further edits.

<img width="477" alt="Screenshot 2023-01-06 at 10 41 36 AM" src="https://user-images.githubusercontent.com/7525989/211077599-482536ef-1a70-4f58-abf0-314c773c64c6.png">

### `/imagine`

Creates an image from a text prompt. (e.g. `/imagine cute kitten riding a skateboard`)

Available options:
- Aspect Ratio
  - `--ar <width>:<height>` (e.g. `/imagine cute kitten riding a skateboard --ar 16:9`)
  - Uses the default width or height, and calculates the final value for the other based on the aspect ratio. It then rounds that value up to the nearest multiple of `8`, to match the expectations of the underlying neural model and SD API.
  - Under the hood, it will use the "Hires fix" option in the API, which will generate an image with the bot's default width/height, and then resize it to the desired aspect ratio.

## How it Works

The bot implements a FIFO queue (first in, first out). When a user issues the `/imagine` command (or uses an interaction button), they are added to the end of the queue.

The bot then checks the queue every second. If the queue is not empty, and there is nothing currently being processed, it will send the top interaction to the Automatic1111 WebUI API, and then remove it from the queue.

After the Automatic1111 has finished processing the interaction, the bot will then update the reply message with the finished result.

Buttons are added to the Discord response message for interactions like re-roll, variations, and up-scaling.

All image generations are saved into a local SQLite database, so that the parameters of the image can be retrieved later for variations or up-scaling.

<img width="846" alt="Screenshot 2022-12-22 at 4 25 03 PM" src="https://user-images.githubusercontent.com/7525989/209247258-8c637265-b0b2-419a-98c6-95c4bb78504f.png">

<img width="667" alt="Screenshot 2022-12-22 at 4 25 18 PM" src="https://user-images.githubusercontent.com/7525989/209247280-4318a73a-71f4-48aa-8310-7fdfbbbf6820.png">

Options like aspect ratio are extracted and sanitized from the text prompt, and then the resulting options are stored in the database record for the image generation (for further variations or upscaling):

<img width="995" alt="Screenshot 2022-12-28 at 4 30 43 PM" src="https://user-images.githubusercontent.com/7525989/209888645-b616fbb1-955a-4d3e-9a25-ce43baa6cfbd.png">
