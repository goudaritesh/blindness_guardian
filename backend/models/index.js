const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

// User Model
const User = sequelize.define('User', {
    id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
    email: { type: DataTypes.STRING, unique: true, allowNull: false },
    password: { type: DataTypes.STRING, allowNull: false },
    name: { type: DataTypes.STRING },
    geo_fence_radius: { type: DataTypes.DOUBLE, defaultValue: 500 }
});

// Device Model
const Device = sequelize.define('Device', {
    id: { type: DataTypes.STRING, primaryKey: true }, // Device ID like STICK_001
    status: { type: DataTypes.ENUM('online', 'offline'), defaultValue: 'offline' },
    battery: { type: DataTypes.INTEGER, defaultValue: 0 },
    signal: { type: DataTypes.INTEGER, defaultValue: 0 },
    lastSeen: { type: DataTypes.DATE }
});

// LocationLog Model
const LocationLog = sequelize.define('LocationLog', {
    deviceId: { type: DataTypes.STRING, allowNull: false },
    lat: { type: DataTypes.DOUBLE, allowNull: false },
    lng: { type: DataTypes.DOUBLE, allowNull: false },
    timestamp: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
});

// Alert Model
const Alert = sequelize.define('Alert', {
    deviceId: { type: DataTypes.STRING, allowNull: false },
    type: { type: DataTypes.STRING, allowNull: false }, // SOS, FALL
    lat: { type: DataTypes.DOUBLE },
    lng: { type: DataTypes.DOUBLE },
    imageUrl: { type: DataTypes.STRING },
    resolved: { type: DataTypes.BOOLEAN, defaultValue: false },
    timestamp: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
});

// Relationships
User.hasMany(Device);
Device.belongsTo(User);

module.exports = { User, Device, LocationLog, Alert };
