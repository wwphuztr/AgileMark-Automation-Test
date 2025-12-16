# Images Directory

This directory stores reference images used by SikuliX for UI element recognition.

## 📸 How to Add Images

1. **Capture Screenshots:**
   - Use SikuliX IDE or any screenshot tool
   - Capture UI elements you want to interact with (buttons, fields, icons, etc.)

2. **Naming Convention:**
   - Use descriptive names: `login_button.png`, `username_field.png`
   - Use lowercase with underscores
   - Include context when needed: `main_menu_settings.png`

3. **Image Quality:**
   - Save as PNG format (preferred)
   - Ensure good contrast and clarity
   - Capture at the same screen resolution where tests will run

## 📁 Organize Images

Consider organizing images in subdirectories for better management:

```
images/
├── login/
│   ├── username_field.png
│   ├── password_field.png
│   └── login_button.png
├── main_menu/
│   ├── menu_icon.png
│   ├── settings_option.png
│   └── logout_option.png
└── forms/
    ├── submit_button.png
    └── cancel_button.png
```

## 💡 Tips

- Capture images at different states (normal, hover, clicked) if needed
- Keep backup of important images
- Test image recognition with different screen resolutions
- Update images when UI changes

## 🔍 Example Images Needed

For the example tests to work, you'll need to capture:

- `app_launcher.png` - Application icon/launcher
- `login_button.png` - Login button
- `username_field.png` - Username input field
- `password_field.png` - Password input field
- `home_screen.png` - Home screen after login
- `menu_icon.png` - Main menu icon
- `settings_title.png` - Settings page header
- `back_button.png` - Back navigation button
- And others as referenced in test files

Place your captured images here and update the test files accordingly.
