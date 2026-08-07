import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueJsx from '@vitejs/plugin-vue-jsx'

import AutoImport from 'unplugin-auto-import/vite'
import Components from 'unplugin-vue-components/vite'
import { ElementPlusResolver } from 'unplugin-vue-components/resolvers'

export default defineConfig({
  base: './',
  plugins: [
    vue(),
    vueJsx(),
    AutoImport({
      resolvers: [ElementPlusResolver()],
    }),
    Components({
      resolvers: [ElementPlusResolver()],
    }),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  server: {
    proxy: {
      // 1. AIModuleServer 相关接口（业务接口）
      '/api/AIModuleServer': {
        target: 'http://localhost:83',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api\/AIModuleServer/, '')
      },
      // 2. Detection 相关接口（检测接口）
      '/api/Detection': {
        target: 'http://localhost:83',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      },
      // 3. results 静态资源（检测结果图片）
      '/results': {
        target: 'http://localhost:83',
        changeOrigin: true
      },
      // 4. 其他 /api 请求（默认）
      '/api': {
        target: 'http://localhost:80',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  }
})