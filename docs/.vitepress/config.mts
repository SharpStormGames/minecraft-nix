import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Minecraft-Nix Docs",
  description: "Documentation for minecraft-nix",
  base: "/minecraft-nix/",
  themeConfig: {
    search: { 
      provider: 'local', 
      options: {
        detailedView: true,
      },
    },
    externalLinkIcon: true,
    sidebar: [
      { text: 'Initial Setup', link: '/' },
      { text: 'Extra Options', link: '/opts.md' },
      {
        text: 'Loaders',
        collapsed: true,
        items: [
          {
            text: '',
            base: '/loaders/',
            items: [
              { text: 'Fabric', link: 'fabric' },
              { text: 'Forge', link: 'forge' },
              { text: 'Liteloader', link: 'liteloader' },
              { text: 'Quilt', link: 'quilt' },
            ]
          }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/sharpstormgames/minecraft-nix' }
    ]
  }
})
