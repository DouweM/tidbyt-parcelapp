# Tidbyt + ParcelApp

[Tidbyt](https://tidbyt.com/) app that shows the upcoming delivery tracked using [ParcelApp](https://parcelapp.net/).

![Screenshot](screenshot.webp)

## Installation

This app is not available through Tidbyt's mobile app as it uses features that (for security reasons) are not supported in [community apps](https://tidbyt.dev/docs/publish/community-apps) that run on Tidbyt's official app server.

Instead, it needs to be run using [Pixbyt](https://pixbyt.dev), a self-hosted Tidbyt app server for advanced apps.

### 1. Set up Pixbyt

1. [Create your own Pixbyt repo](https://github.com/DouweM/pixbyt#1-create-your-own-pixbyt-repo)
2. [Configure your Tidbyt](https://github.com/DouweM/pixbyt#2-configure-your-tidbyt)

### 2. Install the app

1. Add this repo as a submodule under `apps`:

    ```bash
    git submodule add https://github.com/DouweM/tidbyt-parcelapp.git apps/parcelapp
    ```

1. Add an update schedule to `apps.yml` under `schedules:`:

    ```yaml
    schedules:
    # ...
    - name: parcelapp
      interval: '*/15 * * * *' # Every 15 minutes
      job: parcelapp
    ```

## Configuration

1. Find your ParcelApp Web Token by signing in on <https://web.parcelapp.net/> and finding the value of the `account_token` cookie.

1. Update `.env` with your configuration:

   ```bash
   PARCELAPP_TOKEN="<token>"
   ```

## Usage

Build and launch your Pixbyt app server:

1. [Build the app server](https://github.com/DouweM/pixbyt#4-build-the-app-server)
1. [Launch the app server](https://github.com/DouweM/pixbyt#5-launch-the-app-server)
