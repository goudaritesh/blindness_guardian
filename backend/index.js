const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
require('dotenv').config();
const sequelize = require('./config/db');
const { User, Device, LocationLog, Alert } = require('./models');
const authRoutes = require('./routes/auth');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
    cors: { origin: "*", methods: ["GET", "POST"] }
});

app.use(cors());
app.use(express.json());
app.use('/api/auth', authRoutes);

// Socket.io Real-time connection
io.on('connection', (socket) => {
    console.log('Client connected:', socket.id);

    socket.on('join_device', (deviceId) => {
        socket.join(deviceId);
        console.log(`Socket ${socket.id} joined device room: ${deviceId}`);
    });

    socket.on('disconnect', () => {
        console.log('Client disconnected');
    });
});

// --- API Endpoints for IoT (ESP32) ---

// 1. Update Location (ESP32 calls this)
app.post('/api/iot/location', async (req, res) => {
    const { deviceId, lat, lng } = req.body;
    try {
        const log = await LocationLog.create({ deviceId, lat, lng });
        // Broadcast to App in real-time
        io.to(deviceId).emit('location_update', { lat, lng, timestamp: log.timestamp });
        res.status(200).json({ success: true });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 2. Trigger Alert (ESP32 calls this)
app.post('/api/iot/alert', async (req, res) => {
    const { deviceId, type, lat, lng, imageUrl } = req.body;
    try {
        const alert = await Alert.create({ deviceId, type, lat, lng, imageUrl });
        // Broadcast Emergency to App in real-time
        io.to(deviceId).emit('emergency_alert', alert);
        res.status(200).json({ success: true });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 3. Update Status (Heartbeat)
app.post('/api/iot/status', async (req, res) => {
    const { deviceId, battery, signal } = req.body;
    try {
        await Device.update(
            { battery, signal, status: 'online', lastSeen: new Date() },
            { where: { id: deviceId } }
        );
        io.to(deviceId).emit('status_update', { battery, signal, status: 'online' });
        res.status(200).json({ success: true });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- App Endpoints (Flutter) ---

app.get('/api/alerts/:deviceId', async (req, res) => {
    try {
        const alerts = await Alert.findAll({
            where: { deviceId: req.params.deviceId },
            order: [['timestamp', 'DESC']]
        });
        res.json(alerts);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.put('/api/alerts/:alertId/resolve', async (req, res) => {
    try {
        await Alert.update({ resolved: true }, { where: { id: req.params.alertId } });
        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.get('/api/users/:userId/settings', async (req, res) => {
    try {
        const user = await User.findByPk(req.params.userId);
        if (!user) return res.status(404).json({ error: 'User not found' });
        res.json({ geo_fence_radius: user.geo_fence_radius });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.put('/api/users/:userId/settings', async (req, res) => {
    try {
        const { geo_fence_radius } = req.body;
        await User.update({ geo_fence_radius }, { where: { id: req.params.userId } });
        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.get('/api/stats/:deviceId', async (req, res) => {
    try {
        // Just returning mockup for now, since we haven't implemented logic to record these
        res.json({
            obstacles_avoided: 12,
            safe_hours: 4.5
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Sync Database & Start Server
const PORT = process.env.PORT || 5000;
sequelize.sync().then(() => {
    server.listen(PORT, () => console.log(`Guardian Server running on port ${PORT}`));
}).catch(err => {
    console.error('Unable to connect to database:', err);
});
