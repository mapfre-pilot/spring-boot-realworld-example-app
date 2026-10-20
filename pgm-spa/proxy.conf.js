/** Proxy del dev-server: /api y /monitoring → BFF. En dev container compose el BFF es `http://bff:8080` (PGM_BFF_URL). */
const target = process.env.PGM_BFF_URL || 'http://localhost:8080';
module.exports = {
  '/api': { target, secure: false, changeOrigin: true },
  '/monitoring': { target, secure: false, changeOrigin: true },
};
