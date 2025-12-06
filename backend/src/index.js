import express from 'express'
import cors from 'cors'

const app = express()
const PORT = process.env.PORT || 3000

app.use(cors())
app.use(express.json())

// Ejemplo simple de endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', service: 'hotel-backend' })
})

// Aquí luego conectas Supabase, rutas reales, etc.

app.listen(PORT, () => {
  console.log(`Backend escuchando en puerto ${PORT}`)
})
