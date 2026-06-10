# Settings Module — Mobile

## Purpose

Allow the freelancer to manage their account, preferences, and notification settings.

## Responsibilities

- View / edit user profile (name, email, avatar)
- Manage notification preferences (channels: push, email, Zalo)
- View subscription plan and AI usage counters
- Change password
- Log out
- Dark / light mode toggle

## API Endpoints

- `GET /users/me` — current user profile
- `PUT /users/me` — update profile
- `GET /users/me/preferences` — notification preferences
- `PUT /users/me/preferences` — update preferences
