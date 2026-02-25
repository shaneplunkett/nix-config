// Stub implementation of @ant/claude-native for Linux
// Uses Electron's native Linux support where possible instead of no-ops
const KeyboardKey = { Backspace: 43, Tab: 280, Enter: 261, Shift: 272, Control: 61, Alt: 40, CapsLock: 56, Escape: 85, Space: 276, PageUp: 251, PageDown: 250, End: 83, Home: 154, LeftArrow: 175, UpArrow: 282, RightArrow: 262, DownArrow: 81, Delete: 79, Meta: 187 };
Object.freeze(KeyboardKey);

// Helper: get the focused BrowserWindow (lazy-loaded to avoid circular deps)
function getWindow() {
  try {
    const { BrowserWindow } = require('electron');
    const focused = BrowserWindow.getFocusedWindow();
    if (focused) return focused;
    const win = BrowserWindow.getAllWindows().find(
      (w) => !w.isDestroyed()
    );
    return win || null;
  } catch (e) {
    console.warn('[Claude Native Stub] getWindow() failed:', e);
    return null;
  }
}

class AuthRequest {
  static isAvailable() {
    return false;
  }

  async start(url, scheme, windowHandle) {
    throw new Error('AuthRequest not available on Linux');
  }

  cancel() {}
}

module.exports = {
  getWindowsVersion: () => "10.0.0",
  setWindowEffect: () => {},
  removeWindowEffect: () => {},

  getIsMaximized: () => {
    const win = getWindow();
    return win ? win.isMaximized() : false;
  },

  flashFrame: (flash) => {
    const win = getWindow();
    if (win) win.flashFrame(typeof flash === 'boolean' ? flash : true);
  },
  clearFlashFrame: () => {
    const win = getWindow();
    if (win) win.flashFrame(false);
  },

  showNotification: () => {},

  setProgressBar: (progress) => {
    const win = getWindow();
    if (win && typeof progress === 'number') {
      win.setProgressBar(Math.max(0, Math.min(1, progress)));
    }
  },
  clearProgressBar: () => {
    const win = getWindow();
    if (win) win.setProgressBar(-1);
  },

  setOverlayIcon: () => {},
  clearOverlayIcon: () => {},
  KeyboardKey,
  AuthRequest
};
