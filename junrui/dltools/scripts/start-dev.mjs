import { spawn } from 'node:child_process'
import { closeSync, existsSync, openSync } from 'node:fs'
import { connect } from 'node:net'
import { dirname, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

const frontendRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const projectRoot = resolve(frontendRoot, '../..')
const jarPath = resolve(projectRoot, 'Java_proj/idtserver/mrserver/ai/target/ai-1.0-SNAPSHOT.jar')
const vitePath = resolve(frontendRoot, 'node_modules/vite/bin/vite.js')

const isBackendRunning = () => new Promise((done) => {
  const socket = connect({ host: '127.0.0.1', port: 83 })
  socket.setTimeout(800)
  socket.once('connect', () => {
    socket.destroy()
    done(true)
  })
  socket.once('timeout', () => {
    socket.destroy()
    done(false)
  })
  socket.once('error', () => done(false))
})

if (!(await isBackendRunning())) {
  if (!existsSync(jarPath)) {
    console.error('[AIModuleServer] Backend jar is missing. Run Maven package first.')
    process.exit(1)
  }
  const bundledJava = 'D:/Java/jdk-1.8/bin/java.exe'
  const javaCommand = existsSync(bundledJava) ? bundledJava : 'java'
  const outputLog = openSync(resolve(projectRoot, 'backend-ai.log'), 'a')
  const errorLog = openSync(resolve(projectRoot, 'backend-ai.err.log'), 'a')
  const backend = spawn(javaCommand, ['-Xms128m', '-Xmx512m', '-jar', jarPath], {
    cwd: projectRoot,
    detached: true,
    stdio: ['ignore', outputLog, errorLog],
    windowsHide: true,
  })
  backend.unref()
  closeSync(outputLog)
  closeSync(errorLog)
  console.log(`[AIModuleServer] Backend started independently (PID ${backend.pid ?? 'unknown'}).`)
  console.log('[AIModuleServer] Initial startup may take about 80 seconds.')
} else {
  console.log('[AIModuleServer] Reusing backend on port 83.')
}

const vite = spawn(process.execPath, [vitePath, ...process.argv.slice(2)], {
  cwd: frontendRoot,
  stdio: 'inherit',
})

vite.once('exit', (code) => process.exit(code ?? 0))
