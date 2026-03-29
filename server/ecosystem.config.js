module.exports = {
  apps: [
    {
      name: 'throneroom',
      script: 'index.js',
      instances: 1,
      autorestart: true,
      max_memory_restart: '750M',
      watch: true,
      env: {},
    },
  ],
}
